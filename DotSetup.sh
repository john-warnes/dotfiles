#!/bin/bash

# Written by John Warnes
# Based on vimrc setup from Hugo Valle
# Modify on May-29-2017 by Hugo V. to fit my setup

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  DetectOS
#   DESCRIPTION:  Set variables detecting the OS type
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'

set -o nounset

clear

#
#    MAC OS fix bash completion
#
#   brew install bash-completion
#   brew install git
#   brew link git
#

DetectOS()
{
    # IDs help ---> https://github.com/zyga/os-release-zoo
    SUPPORTEDDISTROS="ubuntu, linuxmint, debian, elementary OS, neon, peppermint, Zorin OS"

    source scripts/detectOS

#    case "$OSTYPE" in
#        solaris*) OS="SOLARIS" ;;
#        darwin*)  OS="OSX" ;;
#        linux*)   OS="LINUX" ;;
#        bsd*)     OS="BSD" ;;
#        msys*)    OS="WINDOWS" ;;
#        *)        OS="unknown: $OSTYPE" ;;
#    esac
#
    if [[  $OS == 'LINUX' ]]; then
        if [[  $SUPPORTEDDISTROS != *$ID* ]]; then
            echo "$BOLD${RED}ERROR:$RESET Undetected Linux: $ID $RESET"
            echo "Supported:$BOLD$BLUE $SUPPORTEDDISTROS $RESET"
            read -n 1 -p "Attempt to continue? $RESET (y/N): $GREEN" choice
            echo "$RESET"
            case "$choice" in
                y|Y ) :;;
                n|N|* ) echo "$RESET";exit -1;;
            esac
        else
            if [[  -z "$PRETTY_NAME" ]]; then
                echo "Linux Detected:$BOLD$GREEN $ID $RESET"
            else
                echo "Linux Detected:$BOLD$GREEN $PRETTY_NAME $RESET"
            fi
        fi

    elif [[  "$OS" == "OSX" ]]; then
        echo "OSX Detected $RESET"
        if which brew 2> /dev/null; then
            echo "$BOLD${YELLOW}Note!$RESET Missing Packages will installed using BREW"
            BREW=1;
        else
            BREW=0
            echo "$BOLD${YELLOW}Note:$RESET OSX:$BOLD$BLUE HomeBrew (https://brew.sh/)$RESET is required for auto install."
            echo "$BOLD${YELLOW}Note:$RESET Missing Packages will be listed."
        fi
    fi


    if [[ $OS == 'LINUX' ]]; then
        APTCMD='sudo apt-get -o Dpkg::Progress-Fancy="1" -y install'
    elif [[ $OS == 'OSX' ]]; then
        APTCMD='brew install'
    fi

}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  ScriptSettings
#   DESCRIPTION:  Setup the settings for this script
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
ScriptSettings()
{
    SCRIPTNAME="WSU JCustom VIM IDE"

    #Directory Setup
    DOTFILES=$HOME/dotfiles
    LOCALBIN=~/.local/bin
    ENV_FILES=($HOME/.bash_profile $HOME/.bash_login $HOME/.profile $HOME/.bashrc $HOME/.zshrc)

    #Optional
    OPTPKGS='clang cppcheck libxml2-utils lua-check jsonlint pylint python3-pip python3-doc ctags cppman'
    PIPPKGS='vim-vint proselint sphinx virtualenvwrapper neovim'

    if [[  $OS == 'LINUX' ]]; then  #LINUX
        PKGS="git bc curl vim\ --with-python3 python3"
    elif [[  $OS == 'OSX' ]]; then  #OSX
        PKGS="git vim python3 curl bc"
    fi

    FILES=($DOTFILES/vim/vimrc $DOTFILES/vim $DOTFILES/tmux/tmux.conf $DOTFILES/vim/vimrc $DOTFILES/git/gitconfig)
    LINKS=(           ~/.vimrc        ~/.vim ~/.tmux.conf             ~/.vimrc            ~/.gitconfig)

    #Global Vars (Auto Set - Changing will have BAD effects)
    ADMIN=0
    WSU=0
    USETMUX=0
    USEZSH=0
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  PrintHelp
#   DESCRIPTION:  Help Function for script. Invoked with --help
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
PrintHelp()
{
    echo "${RESET}usage: $0 [--administrator] [--remove] [--upgrade] [--decrypt] [--backup]$RESET"
    exit 0
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Backup
#   DESCRIPTION:  Make a attempt to backup current vim setup. Invoked with --backup
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
Backup()
{
    echo "${BOLD}Backing up current vim setup$RESET"

    pushd .

    cd $HOME

    BACKUPFILE=.jvimbackup.tar

    if [[ -f $BACKUPFILE ]]; then

        read -n 1 -p "${BOLD}${YELLOW}NOTE: ${RESET}Backup file already exists continuing will replace. Continue (Y/n): $GREEN" choice
        case "$choice" in
            y|Y ) :;;
            n|N ) popd;echo "Canceled$RESET";exit 0;;
            * ) :;;
        esac
        echo "$RESET"

        rm $BACKUPFILE
    fi

    #add .vimrc to tar (create needs to be first)
    tar -vpcf $BACKUPFILE .vimrc

    #append autoexec targets
    tar -vprf $BACKUPFILE .bash_profile
    tar -vprf $BACKUPFILE .bash_login
    tar -vprf $BACKUPFILE .profile
    tar -vprf $BACKUPFILE .bashrc
    tar -vprf $BACKUPFILE .zshrc

    #append other config to tar
    tar -vprf $BACKUPFILE .tmux.conf
    tar -vprf $BACKUPFILE .gitconfig

    #append dir to tar
    tar -vprf $BACKUPFILE .vim

    popd
    exit 0
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  AskRemove
#   DESCRIPTION:  Asks if you want to removes current setup files. Invoke with --remove
#    PARAMETERS:  None
#       RETURNS:  None
#          Note:  There is NO backup.
#-------------------------------------------------------------------------------
AskRemove()
{
    echo "$RESET${RED}REMOVE$RESET Selected$RESET"
    echo "NOTE: If you want a backup run ./DotSetup --backup$RESET"
    read -n 1 -p "$BOLD${BLUE}Remove all configuration and files?$RESET (y/N): $GREEN" choice
    echo ""
    case "$choice" in
        y|Y ) :;;
        n|N ) echo "Canceled$RESET";exit 0;;
        * ) echo "Canceled$RESET";exit 0;;
    esac

    Remove
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Remove
#   DESCRIPTION:  Removes current setup files.
#    PARAMETERS:  None
#       RETURNS:  None
#          Note:  There is NO backup.
#-------------------------------------------------------------------------------
Remove()
{
    #Unlimk FILES
    for LINK in ${LINKS[@]}
    do
        unlink $LINK 2>/dev/null
    done

    #Delete generated DIRS
    rm -rf $DOTFILES/vim/bundle
    rm -rf $DOTFILES/vim/autoload
    rm -rf $DOTFILES/vim/colors
    rm -rf $DOTFILES/vim/undo

    #Detete FILE created by the setup
    rm -f $DOTFILES/git/gitconfig
    rm -f $DOTFILES/vim/template/personal.template

    rm -f $HOME/.vimrc

    echo "Remove Complete$RESET"
    echo ""
    exit -1
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Upgrade
#   DESCRIPTION:  Upgrade current setup after doing a git pull --upgrade
#    PARAMETERS:  None
#       RETURNS:  None
#          Note:  Might just do a Plug clean install etc
#-------------------------------------------------------------------------------
Upgrade()
{
    unlink ~/.bash_aliases
    unlink ~/.zsh_aliases
    vim +PlugInstall +PlugUpdate +PlugClean +qall
    exit 0
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  DecryptSecure
#   DESCRIPTION:  Decrypt secure file NOTE Must be called after AddToEnvironment
#    PARAMETERS:  none
#       RETURNS:  Success(0) or none
#-------------------------------------------------------------------------------
DecryptSecure()
{
    read -n 1 -p "$BOLD${BLUE}Use secure vault?$RESET (You must have a git repository setup) (y/N): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        y|Y ) :;;
        n|N|* ) return;;
    esac
    read -p "${RESET}Enter$BOLD$BLUE git repository of secure vault$RESET ex\"https://github.com/<user name>/secure.git\": $GREEN" REPO

    (cd $DOTFILES && exec git clone $REPO)
    (exec $DOTFILES/scripts/unlock.sh)
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Init
#   DESCRIPTION:  Initialization of script. Color setup. Folder configuration.
#    PARAMETERS:  $@ Program input choices.
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
Init()
{
    #Check if running as sudo
    # TODO look into sudo -H
    if [[  $EUID == 0 ]]
    then
        echo "Do ${RED}NOT$RESET run this script as root or with sudo$RESET"
        PrintHelp
    fi

    #Check and process command line arguments
    while [[  $# > 0 ]]; do
        case $1 in
            --administrator) ADMIN=1;;
            --remove) AskRemove;;
            --upgrade) Upgrade;;
            --decrypt) DecryptSecure;;
            --backup) Backup;;
            --hidden) neovimSetup; exit 0;;
            -h|--help|*) PrintHelp;;
        esac;
        shift;
    done

    echo "Installing$BOLD$BLUE $SCRIPTNAME$RESET"

    if [[ $ADMIN == 1 ]]; then
        echo "Admin Mode is:$BOLD$GREEN ON $RESET"
    fi

}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CheckOptional
#   DESCRIPTION:  Check for recommended but optional packages
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CheckOptional()
{
    echo -n "Checking for optional packages:$RESET"
    ERRFLAG=false

    for PKG in $OPTPKGS; do
        if which $PKG 1>/dev/null 2>/dev/null; then
            echo -n "$BOLD$GREEN $PKG$RESET"
        else
            echo -n "$BOLD$YELLOW $PKG$RESET"
            ERRFLAG=true
        fi
    done
    echo ""
    if [[  $ERRFLAG ]]; then
        echo "$BOLD${YELLOW}Note:$RESET Recommended$BOLD$YELLOW NOT$RESET required package missing."
        unset ERRFLAG
    fi
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CheckDeps
#   DESCRIPTION:  Verifies system dependencies
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CheckDeps()
{
    printf "Checking for Required Packages:$RESET"
    ERRFLAG=0

    for PKG in $PKGS; do
        if which $PKG 1>/dev/null 2>/dev/null; then
            printf "$BOLD$GREEN $PKG$RESET"
        else
            printf "$BOLD$RED $PKG$RESET"
            ERRFLAG=1
        fi
    done
    echo ""

    #if [[ $ERRFLAG == 1 ]] && [[ $ADMIN == 0 ]]; then
    if (( $ERRFLAG )) && (( ! $ADMIN )); then
            echo ""
            echo "$BOLD${RED}ERROR:$RESET Missing Required Package: RUN:$BOLD$BLUE \"$0 --administrator\"$RESET attempt to fix $RESET"
            echo ""
            exit -1
    fi
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CheckVim
#   DESCRIPTION:  Verifies a good vim
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
#CheckVim()
#{
#
#    VIMS=(vim-gnome vim-gtk vim-athena vim-nox vim)
#
#    printf "Checking vim:$RESET"
#    ERRFLAG=false
#
#    for PKG in $PKGS; do
#        if [[  $(which $PKG | grep -o "$PKG") ]]; then
#            printf "$BOLD$GREEN $PKG$RESET"
#        else
#            printf "$RED $PKG$RESET"
#            ERRFLAG=true
#        fi
#    done
#    echo ""
#
#    if [[  $ERRFLAG ]]; then
#        if  $ADMIN != 1 ]]; then
#            echo ""
#            echo "${RED}ERROR:$RESET Missing Required Package: RUN:$BOLD$BLUE \"$0 --administrator\"$RESET attempt to fix $RESET"
#            echo ""
#            exit -1
#        fi
#    fi
#}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Setup
#   DESCRIPTION:  Setup function for tmux, zsh
#    PARAMETERS:  None
#       RETURNS:  If selected, appends package setup to OSXPKGS or PKGS
#-------------------------------------------------------------------------------
Setup()
{
    if [[ $OS == 'LINUX' ]]; then
        read -n 1 -p "Use/Install$BOLD$BLUE WSU campus$RESET network IPv6 fix$RESET (Y/n): $GREEN" choice
        echo "$RESET"
        case "$choice" in
            n|N ) WSU=false;;
            y|Y|* ) WSU=true;;
        esac
    fi

    read -n 1 -p "Setup$BOLD$BLUE tmux$RESET (Y/n): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        n|N ) :;;
        y|Y|* ) PKGS+=" tmux";OSXPKGS+=" tmux"; USETMUX=true;;
    esac

    read -n 1 -p "Setup$BOLD$BLUE zsh$RESET (Y/n): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        n|N ) :;;
        y|Y|* ) PKGS+=" zsh";OSXPKGS+=" zsh"; USEZSH=true;;
    esac
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  AdminSetup
#   DESCRIPTION:  Administrator setup. Will required sudo access to the machine
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#          NOTE:  Only needed once on each computer
#-------------------------------------------------------------------------------
AdminSetup()
{
    echo "$BOLD${BLUE}Admin Setup$RESET ($OS)"
    ERRFLAG=false
    APTOPT=''

    # Fix for apt-get linuxes and wsu ipv6 firewall
    if [[  $OS == 'LINUX' ]]; then
        if [[ "$WSU" == true ]]; then
            # Fixes for Ubuntu and IPv6 inside WSU
            echo "Adding WSU firewall$BOLD$BLUE IPv6 fix$RESET"
            echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
            APTOPT='-o Acquire::ForceIPv4=true'
        fi
    fi

    echo -n "$BOLD${BLUE}Installing Packages: $RESET"
    for PKG in $PKGS; do
        if which $PKG 1>/dev/null 2>/dev/null; then
            echo -n "$BOLD$GREEN $PKG$RESET"
        else
            echo "$BOLD$YELLOW $PKG$RESET"
            $APTCMD $APTOPT $PKG
        fi
    done
    echo ""

    read -n 1 -p "Try to install$BOLD$BLUE Optional$RESET Packages (y/N): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        y|Y ) :;;
        n|N|* ) echo ""; echo ""; return;;
    esac

    echo -n "$BOLD${BLUE}Installing Optional Packages: $RESET"
    for PKG in $OPTPKGS; do
        if which $PKG 1>/dev/null 2>/dev/null; then
            echo -n "$BOLD$GREEN $PKG$RESET"
        else
            echo "$BOLD$YELLOW $PKG$RESET"
            $APTCMD $APTOPT $PKG
        fi
    done

    echo ""
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  GetUserInfo
#   DESCRIPTION:  Capture User information. This is required to setup the
#                 vim and git templates.
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
GetUserInfo()
{
    read -p "${RESET}Enter$BOLD$BLUE Full Name$RESET ex\"John Doe\": $GREEN" name
    read -p "${RESET}Enter$BOLD$BLUE Author Ref$RESET ex\"jdoe\": $GREEN" ref
    read -p "${RESET}Enter$BOLD$BLUE Email Address$RESET ex\"JohnD@mail.weber.edu\": $GREEN" email
    read -p "${RESET}Enter$BOLD$BLUE Company$RESET ex\"Weber State University\": $GREEN" com
    read -p "${RESET}Enter$BOLD$BLUE Organization$RESET ex\"Computer Science\": $GREEN" org
    read -p "${RESET}Enter$BOLD$BLUE Default License line 1$RESET (hit enter for default): $GREEN" license1
    read -p "${RESET}Enter$BOLD$BLUE Default License line 2$RESET (hit enter for default): $GREEN" license2
    if [[ -z "$license1" ]]; then
        license1='This source code is released for free distribution under the terms of the'
        license2='GNU General Public License as published by the Free Software Foundation.'
    fi
    printf "$RESET"
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  InstallPowerLineFonts
#   DESCRIPTION:  Install Powerline Fonts. This is required to display all
#                 special characters in the status bar inside vim.
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
InstallPowerlineFonts()
{
    echo "$RESET"
    # clone fonts
    git clone https://github.com/powerline/fonts.git
    # install fonts
    cd fonts
    ./install.sh
    # clean-up a bit
    cd ..
    rm -rf fonts

    dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'DejaVu Sans Mono for Powerline Book 12'"
    dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-system-font "false"
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CreatePersonalTemplate
#   DESCRIPTION:  Create personal vim templates for c, perl, bash, etc
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CreatePersonalTemplate()
{
echo "Creating User Template File:$BOLD$BLUE $DOTFILES/vim/templates/personal.template.csv$RESET"

printf "AUTHOR,%s
AUTHORREF,%s
EMAIL,%s
ORGANIZATION,%s
COMPANY,%s
LICENSE1,%s
LICENSE2,%s
" "$name" "$ref" "$email" "$org" "$com" "$license1" "$license2" > $DOTFILES/vim/templates/personal.template.csv

echo "Creating User Template File:$BOLD$BLUE $DOTFILES/vim/templates/personal.template$RESET"

printf "§ =============================================================
§  Personal Information
§ =============================================================

SetMacro( 'AUTHOR',       '%s' )
SetMacro( 'AUTHORREF',    '%s' )
SetMacro( 'EMAIL',        '%s' )
SetMacro( 'ORGANIZATION', '%s' )
SetMacro( 'COMPANY',      '%s' )
SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )
SetMacro( 'LICENSE',      '|AUTHOR|' )

§ =============================================================
§  Date and Time Format
§ =============================================================

§SetFormat( 'DATE', '%%x' )
§SetFormat( 'TIME', '%%H:%%M' )
§SetFormat( 'YEAR', '%%Y' )
" "$name" "$ref" "$email" "$org" "$com" > $DOTFILES/vim/templates/personal.template
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CreateGitConfig
#   DESCRIPTION:  Creates basic git configuration file based on input
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CreateGitConfig()
{
    echo "Creating User Git Config:$BOLD$BLUE $DOTFILES/git/gitconfig$RESET"

    printf "
[user]
    name = %s
    email = %s
[core]
    editor = vim
    autocrlf= input
[diff]
    tool = vimdiff
[difftool]
    prompt = false
[merge]
    tool = vimdiff
[help]
    autocorrect = 1
[color]
    ui = auto
    branch = auto
    diff = auto
    interactive = auto
    status = auto
[push]
    default = matching
[credential]
    helper = cache --timeout=28800
[alias]
    export = archive -o latest.tar.gz -9 --prefix=latest/
    amend = !git log -n 1 --pretty=tformat:%%s%%n%%n%%b | git commit -F - --amend
    details = log -n1 -p --format=fuller
    logpretty = log --graph --decorate --pretty=format:'%%C(yellow)%%h%%Creset%%C(auto)%%d%%n%%Creset %%s %%C(green)(%%cr) %%C(blue)<%%an>%%Creset%n'
    logshort = log --graph --decorate --pretty=format:'%%C(yellow)%%h%%Creset -%%C(auto)%%h %%d%%Creset %%s %%C(green)(%%cr) %%C(blue)<%%an>%%Creset' --abbrev-commit
    s = status
    arc = \"!git tag archive/\$1 \$1 -m \\\"Archived on: \$(date '+%%Y-%%m-%%dT%%H:%%M:%%S%%z')\\\" && git branch -D \$1 && git push origin -d \$1 #\"
    arcl = \"!git tag | grep '^archive' #\"
[url \"https://github.com/\"]
    insteadOf = gh:
" "$name" "$email" > $DOTFILES/git/gitconfig
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  ManageFilesAndLinks
#   DESCRIPTION:  Create symbolic links to your ~/dotfiles directory
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
ManageFilesAndLinks()
{
    echo "Creating$BOLD$GREEN symlinks$RESET"
    for ((i=0; i<=${#LINKS[@]}-1;i++))
    do
        echo "Linked$BOLD$GREEN ${LINKS[${i}]} $RESET->$BOLD$BLUE ${FILES[${i}]} $RESET"
        ln -s ${FILES[${i}]} ${LINKS[${i}]}
    done

    echo "Downloading Colors wombat256mod.vim"
    mkdir -p $DOTFILES/vim/colors
    wget -O $DOTFILES/vim/colors/wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400

    #if [[  -f ~/.zshrc && $ZSH == true ]]; then
    #    echo "Appending soruces to$BOLD$GREEN ~/.zshrc$RESET"
    #    echo "source ~/.zsh_aliases" >> ~/.zshrc
    #fi

    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  PatchPlugs
#   DESCRIPTION:  Patch Plugins
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
PatchPlugs()
{
    echo "Patching NerdTree:$RESET$BOLD$BLUE $DOTFILES/vim/bundle/nerdtree/nerdtree_plugin/NerdTreePatch.vim$RESET"
    mkdir -p $DOTFILES/vim/bundle/nerdtree/nerdtree_plugin
    ln -s $DOTFILES/vim/patches/NerdTreePatch.vim $DOTFILES/vim/bundle/nerdtree/nerdtree_plugin/NerdTreePatch.vim
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  AddToEnvironment
#   DESCRIPTION:  Add need variables to environment
#    PARAMETERS:  none
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
AddToEnvironment()
{
    echo "Add Environment Var:$RESET$BOLD$BLUE \$DOTFILES=$RESET$DOTFILES"

    for RCFILE in "${ENV_FILES[@]}"
    do
        if [[  -e ${RCFILE} ]]; then
            if grep -q "export DOTFILES=" "$RCFILE" 2>/dev/null; then
                echo "$BOLD$GREEN $RCFILE$RESET:$BOLD$BLUE Already added$RESET skipping"
            else
                echo "Adding to file:$BOLD$GREEN $RCFILE$RESET"
                echo "export DOTFILES=\"$DOTFILES\"" >> $RCFILE
                echo "export PATH=\"\$PATH:$DOTFILES/scripts\"" >> $RCFILE
                echo "source $DOTFILES/shell/autorun.sh" >> $RCFILE
            fi
        else
           echo "$YELLOW${BOLD}Note:$RESET$BOLD $RCFILE$RESET does not exist"
        fi
   done

    if [[  $OS == 'OSX' ]]; then
        touch ~/.bash_profile
        RCFILE="~/.bash_profile"
        echo "Adding to file:$BOLD$GREEN $RCFILE$RESET"
        echo "export DOTFILES=\"$DOTFILES\"" >> $RCFILE
        echo "export PATH=\"\$PATH:$DOTFILES/scripts\"" >> $RCFILE
        echo "source $DOTFILES/shell/autorun.sh" >> $RCFILE
    fi

    #Also export then for any subscript this script runs
    export DOTFILES="$DOTFILES"
    export PATH="$PATH:$DOTFILES/scripts"
    echo ""
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  neovimSetup
#   DESCRIPTION:  Add config to start nvim support
#    PARAMETERS:  none
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
neovimSetup()
{
    set +o nounset
    set +u

    echo "Creating$BOLD$GREEN neovim init.vim$RESET"
    NVIMCFGPATH=$HOME/.config/nvim
    if [[ -n "$XDG_CONFIG_HOME" ]]; then
        NVIMCFGPATH=$XDG_CONFIG_HOME/nvim
    fi

    mkdir -p $NVIMCFGPATH

    printf 'set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc' > $NVIMCFGPATH/init.vim

    echo "Created:$BOLD$BLUE $NVIMCFGPATH/init.vim$RESET"


    set -o nounset
    set -u
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  main
#   DESCRIPTION:  This is the main driver function.
#    PARAMETERS:  Optional parameters: --help, --administrator, --remove
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
main()
{
    source scripts/colors.sh
    DetectOS
    ScriptSettings
    Init "$@"     # Remember to pass the command line args $@
    Setup
    CheckDeps

    if [[ $ADMIN == 1 ]]; then
    CheckOptional
        AdminSetup
    fi

    GetUserInfo   # Get user information

    ManageFilesAndLinks   #Create Dirs Copy Files and Make Links

    AddToEnvironment

    #Install Powerline Fonts?
    read -n 1 -p  "Install$BOLD$BLUE PowerLine Fonts$RESET (Y/n): $GREEN" choice
    case "$choice" in
        n|N ) :;;
        y|Y|* ) InstallPowerlineFonts;;

    esac
    echo "$RESET"

    CreatePersonalTemplate
    CreateGitConfig

    vim +PlugInstall +qall #Installs the vim plugin system and updates all plugins

    PatchPlugs
    DecryptSecure

    neovimSetup

    if [[ "$USEZSH" == true ]]; then
        echo "Downloading and installing: oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        AddToEnvironment
    fi

    echo '      _       _                 _     _         '
    echo '     (_)_   _(_)_ __ ___       (_) __| | ___    '
    echo '     | \ \ / / | `_ ` _ \ _____| |/ _` |/ _ \   '
    echo '     | |\ V /| | | | | | |_____| | (_| |  __/   '
    echo '    _/ | \_/ |_|_| |_| |_|     |_|\__,_|\___|   '
    echo '   |__/                    ${BOLD}Enjoy a better vim$RESET   '
    echo ''

}
main "$@"     #remember to pass all command line args
