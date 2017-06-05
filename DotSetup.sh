#!/bin/bash

# Written by John Warnes
# Based on vimrc setup from Hugo Valle
# Modify on May-29-2017 by Hugo V. to fit my setup

#echo "arg: $@"    # Debug

#Directory Setup
DOTFILES=~/dotfiles
VIMDIR=~/.vim
OHMYZSH=~/.oh-my-zsh

LOCALBIN=~/.local/bin

# TODO Needed dependency checking of the vim package
# Recommended any vim package in this order: vim-gnome vim-gtk vim-athena vim-nox vim

#Packages Lists (Manually Set)
OPTIONALPKGS="clang cppcheck libxml2-utils lua-check jsonlint pylint python3-pip"
# == Recommanded ==
#SQL              sqlint      gem install sqlint
#VIML,Vim         vlit        pip install vim-vint
#Multi,Others     proselint   pip install proselint


#Global Vars (Manually Set)
SCRIPTNAME="WSU JW-Custom VIM IDE"
PKGS="git exuberant-ctags vim-gnome python3-doc"
OSXPKGS="git ctags vim python3"

# IDs help ---> https://github.com/zyga/os-release-zoo
SUPPORTEDDISTROS="ubuntu, linuxmint, debian, elementary OS, neon, peppermint, Zorin OS"


#Global Vars (Auto Set - Changing will have BAD effects)
REMOVE=false
FILENAME=$0
ADMIN=false
WSU=false
TMUX=false
ZSH=false
OS=""



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  PrintHelp
#   DESCRIPTION:  Help Function for script. Invoked with --help
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
PrintHelp()
{
    echo "$RESET${BOLD}useage: $0 [--administrator] [--remove] [--upgrade]$RESET"
    exit -1
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Remove
#   DESCRIPTION:  Removes current setup files. Invoke with --remove
#    PARAMETERS:  None
#       RETURNS:  None
#          Note:  There is NO backup.
#-------------------------------------------------------------------------------
Remove()
{
    echo "$RESET$BOLD${RED}REMOVE$RESET$BOLD Selected$RESET"
    echo "${BOLD}NOTE: Their is not backup are you sure?$RESET"
    read -n 1 -p "$RESET$BLUE${BOLD}Remove all configuration and files? $RESET$BOLD (y/N): $GREEN" choice
    echo ""
    case "$choice" in
        y|Y ) :;;
        n|N ) echo "${BOLD}Canceled$RESET";exit -1;;
        * ) echo "${BOLD}Canceled$RESET";exit -1;;
    esac

    #links and files
    rm -f ~/.vimrc ~/.bash_aliases ~/.zsh_aliases ~/.zshrc ~/.tmux.conf ~/.gitconfig ~/.personal_aliases
    rm $LOCALBIN/git_diff_wrapper.sh

    #directorys
    rm -rf $OHMYZSH

    #dont just delete the hole vimdirector
    rm -rf $VIMDIR/bundle
    rm -rf $VIMDIR/autoload
    rm -rf $VIMDIR/colors

    #auto createfile
    rm -f $DOTFILES/git/gitconfig
    rm -f $DOTFILES/vim/template/personal.template

    #links of directroys
    unlink ~/.vim 2>/dev/null

    echo "${BOLD}Remove Complete$RESET"
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
    vim +PlugClean +PlugInstall +PlugUpdate +qall
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Init
#   DESCRIPTION:  Initialization of script. Color setup. Folder configuration.
#    PARAMETERS:  $@ Program input choices.
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
Init()
{
    # Use colors, but only if connected to a terminal, and that terminal
    # supports them.
    if which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        RESET="$(tput sgr0)"
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi

    if [ "$EUID" = 0 ]
    then
        echo "${BOLD}Do ${RED}NOT$RESET$BOLD run this script as root or with sudo$RESET"
        PrintHelp
    fi

    #echo "Function Args: $@"    #debug

    while [[ "$#" > 0 ]]; do

        #echo "while Args: $@"    #debug
        case $1 in
            --administrator) ADMIN=true;;
            --remove) REMOVE=true;;
            --upgrade) UPGRADE=true;;
            -h | --help | *) PrintHelp;;
        esac;
        shift;
    done

    if [ "$REMOVE" = true ]; then
        Remove
    fi

    if [ "$UPGRADE" = true ]; then
        Upgrade
    fi

    clear
    echo "${BOLD}Installing$GREEN $SCRIPTNAME $RESET$BOLD(vim/tmux/zsh/git)$RESET"
    echo ""

    if [ "$ADMIN" = true ]; then
        echo "${BOLD}Admin Mode is:$GREEN ON"
    fi

    case "$OSTYPE" in
        solaris*) OS="SOLARIS" ;;
        darwin*)  OS="OSX" ;;
        linux*)   OS="LINUX" ;;
        bsd*)     OS="BSD" ;;
        msys*)    OS="WINDOWS" ;;
        *)        OS="unknown: $OSTYPE" ;;
    esac

    if [ "$OS" == "LINUX" ]; then

        source /etc/os-release    #Load OS VARS

        if [[ $SUPPORTEDDISTROS != *$ID* ]]; then
            echo "$BOLD${RED}ERROR:$RESET$BOLD Undetect Linux: $ID $RESET"
            echo "${BOLD}Supported:$BLUE $SUPPORTEDDIRSTROS $RESET"
            read -n 1 -p "${BOLD}Atempt to install? $RESET$BOLD (y/N): $GREEN" choice
            echo "$RESET"
            case "$choice" in
                y|Y ) :;;
                n|N ) echo "$RESET";exit -1;;
                * ) echo "$RESET";exit -1;;
            esac
        else
            if [ -z "$PRETTY_NAME" ]; then
                echo "${BOLD}Linux Detected:$GREEN $ID $RESET"
            else
                echo "${BOLD}Lunix Detected:$GREEN $PRETTY_NAME $RESET"
            fi

            read -n 1 -p "$RESET${BOLD}Are you installing while on a$BLUE WSU campus$RESET$BOLD network (needs IPv6 fix)$RESET$BOLD (Y/n): $GREEN" choice
            echo "$RESET"
            case "$choice" in
                n|N ) WSU=false;;
                y|Y|* ) WSU=true;;
            esac

        fi

    elif [ "$OS" == "OSX" ]; then

        echo "${BOLD}OSX Detected $RESET"

        if which brew 2> /dev/null; then
            echo "$BOLD${YELLOW}Note!$RESET$BOLD Missing Packages will installed using BREW"
        else
            echo ""
            echo "$BOLD${RED}ERROR:$RESET$BOLD OSX:$BLUE HomeBrew (https://brew.sh/)$RESET$BOLD is required."
            echo ""
            exit -1
        fi

    fi
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CheckOptional
#   DESCRIPTION:  Check for recommended but optional packages
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CheckOptional()
{
    printf "${BOLD}Checking for Recommended Optional Packages:$RESET"
    ERRORFLAG=false

    if [ "$OS" == "LINUX" ]; then

        for PKG in $OPTIONALPKGS; do

            if [ "$(dpkg-query -f='${Status}\n' -W $PKG 2> /dev/null | awk '{print $3;}' 2> /dev/null )" = "installed" ]; then
                printf "$BOLD$GREEN $PKG$RESET"
            else
                printf "$BOLD$YELLOW $PKG$RESET"
                ERRORFLAG=true
            fi
        done
        echo ""

    elif [ "$OS" == "OSX" ]; then

        for PKG in $OPTIONALPKGS; do
            gotit=`which ${PKG} | grep -o "\/${PKG}"`
            if brew list -1 | grep -q "^${PKG}\$"; then
                printf "$BOLD$GREEN $PKG$RESET"
            elif [[ $gotit ]]; then
                printf "$BOLD$GREEN $PKG$RESET"
            else
                printf "$BOLD$YELLOW $PKG$RESET"
                ERRORFLAG=true
            fi
        done
        echo ""
    fi

    if [ "$ERRORFLAG" = true ]; then
        echo "$BOLD${YELLOW}Note:$RESET$BOLD Recommended but not required Packages Missing."
        unset ERRORFLAG
    fi
printf "$BOLD
== Other Recommended Untested for packages ==
$BLUE= Langage =    $YELLOW = package =   $GREEN= Command linux =           = Command OSX =$RESET$BOLD
  SQL             sqlint        gem install sqlint          ?
  Vim, VimL       vim-vint      pip3 install vim-vint       /usr/local/bin/pip install vim-vint
  Many, Others    proselint     pip3 install proselint      /usr/local/bin/pip install proselint
$RESET"
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
    printf "${BOLD}Checking for Required Packages:$RESET"
    ERRORFLAG=false

    if [ "$OS" == "LINUX" ]; then

        for PKG in $PKGS; do

            if [ "$(dpkg-query -f='${Status}\n' -W $PKG 2> /dev/null | awk '{print $3;}' 2> /dev/null )" = "installed" ]; then
                printf "$BOLD$GREEN $PKG$RESET"
            else
                printf "$BOLD$RED $PKG$RESET"
                ERRORFLAG=true
            fi
        done
        echo ""

    elif [ "$OS" == "OSX" ]; then

        for PKG in $OSXPKGS; do
            gotit=`which ${PKG} | grep -o "\/${PKG}"`
            if brew list -1 | grep -q "^${PKG}\$"; then
                printf "$BOLD$GREEN $PKG$RESET"
            elif [[ $gotit ]]; then
                printf "$BOLD$GREEN $PKG$RESET"
            else
                printf "$BOLD$RED $PKG$RESET"
                ERRORFLAG=true
            fi
        done
        echo ""
    fi

    if [ "$ERRORFLAG" = true ]; then
        echo ""
        echo "$BOLD${RED}ERROR:$RESET$BOLD Required Packages Missing: RUN:$BLUE \"$FILENAME --administrator\"$RESET$BOLD to fix $RESET"
        echo ""
        if [ "$ADMIN" = true ]; then
            return
        else
            exit
        fi
    fi
    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Setup
#   DESCRIPTION:  Setup function for tmux, zsh
#    PARAMETERS:  None
#       RETURNS:  If selected, appends package setup to OSXPKGS or PKGS
#-------------------------------------------------------------------------------
Setup()
{
    read -n 1 -p "${BOLD}Setup$BLUE tmux$RESET$BOLD (Y/n): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        n|N ) :;;
        y|Y|* ) PKGS+=" tmux";OSXPKGS+=" tmux"; TMUX=true;;
    esac

    read -n 1 -p "${BOLD}Setup$BLUE zsh$RESET$BOLD (Y/n): $GREEN" choice
    echo "$RESET"
    case "$choice" in
        n|N ) :;;
        y|Y|* ) PKGS+=" zsh";OSXPKGS+=" zsh"; ZSH=true;;
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
    echo "$BLUE${BOLD}Admin Setup$RESET$BOLD ($OS)"

    if [ $OS == 'LINUX' ]; then

        if [ 1 -eq "$(echo "${VERSION} < 16.04" | bc)" ]; then
            echo "$RESET${RED}ERROR:$RESET$BOLD$BLUE Dectect Verion($VERSION) Required: >16.04$RESET"
            exit -1
        fi

        if [ "$WSU" = true ]; then
            # Fixes for Ubuntu and IPv6 inside WSU
            echo "$RESET${BOLD}Adding WSU firewall$BLUE IPv6 fix$RESET$BOLD"
            sudo echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
        fi

        echo "${BOLD}Updating Available Packages$RESET"

        if [ "$WSU" = true ]; then
            sudo apt-get -o Acquire::ForceIPv4=true -o Dpkg::Progress-Fancy="1" -y update
        else
            sudo apt-get -o Dpkg::Progress-Fancy="1" -y update
        fi

        echo "${BOLD}Required Package List:$GREEN $PKGS $RESET"

        for PKG in $PKGS; do
            printf "${BOLD}Checking $PKG:"

            if [ "$(dpkg-query -f='${Status}\n' -W $PKG | awk '{print $3;}')" = "installed" ]; then
                echo "$GREEN Found$RESET"
            else
                echo "$RED Not Found"
                echo "$YELLOW    Installing$BLUE $PKG$RESET"

                if [ "$WSU" = true ]; then
                    sudo apt-get -o Acquire::ForceIPv4=true -o Dpkg::Progress-Fancy="1" -y install $PKG
                else
                    sudo apt-get -o Dpkg::Progress-Fancy="1" -y install $PKG
                fi
            fi
        done

    elif [ $OS == 'OSX' ]; then

        echo "${BOLD}Required Package List:$GREEN $OSXPKGS $RESET"
        echo "${BOLD}${YELLOW}Note!$RESET$BOLD When brew may appear to be fozen when installing."
        echo "${BOLD}${YELLOW}     $RESET$BOLD Wait up to 10 mins per package before doing anything"
        echo ""
        for PKG in $OSXPKGS; do
            printf "${BOLD}Checking $PKG:"

            if brew list -1 | grep -q "^${PKG}\$"; then
                echo "$GREEN Found$RESET"
            else
                echo "$RED Not Found"
                echo "$YELLOW    Installing$BLUE $PKG$RESET"
                brew install $PKG
            fi
        done

    fi
    echo "$BLUE${BOLD}Admin Setup$RESET$BOLD End"
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
    read -p "$RESET${BOLD}Enter your$BLUE Full Name$RESET$BOLD Ex\"John Doe\": $GREEN" name
    read -p "$RESET${BOLD}Enter your$BLUE Email Address$RESET$BOLD Ex\"JohnD@mail.weber.edu\": $GREEN" email
    read -p "$RESET${BOLD}Enter your$BLUE Oganization$RESET$BOLD Ex\"WSU\": $GREEN" org
    read -p "$RESET${BOLD}Enter your$BLUE Company$RESET$BOLD Ex\"WSU\": $GREEN" com
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
    echo "${BOLD}Creaing User Template File:$BLUE $VIMDIR/templates/personal.template$RESET"

printf "§ =============================================================
§  Personal Information
§ =============================================================

SetMacro( 'AUTHOR',       '%s' )
SetMacro( 'AUTHORREF',    '' )
SetMacro( 'EMAIL',        '%s' )
SetMacro( 'ORGANIZATION', '%s' )
SetMacro( 'COMPANY',      '%s' )
SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )
SetMacro( 'LICENSE',      'GNU General Public License' )

§ =============================================================
§  Date and Time Format
§ =============================================================

§SetFormat( 'DATE', '%%x' )
§SetFormat( 'TIME', '%%H:%%M' )
§SetFormat( 'YEAR', '%%Y' )
" "$name" "$email" "$org" "$com" > $VIMDIR/templates/personal.template
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  CreateGitConfig
#   DESCRIPTION:  Creates basic git configuration file based on input
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
CreateGitConfig()
{
    echo "${BOLD}Creating User Git Config:$BLUE $VIMDIR/gitconfig$RESET"

printf "
[user]
    name = %s
    email = %s
[core]
    editor = vim
    autocrlf= input
[diff]
    external = git_diff_wrapper.sh
[pager]
    diff =
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
[alias]
    export = archive -o latest.tar.gz -9 --prefix=latest/
    amend = !git log -n 1 --pretty=tformat:%%s%%n%%n%%b | git commit -F - --amend
    details = log -n1 -p --format=fuller
    logpretty = log --graph --decorate --pretty=format:'%%C(yellow)%%h%%Creset -%%C(auto)%%h %%d%%Creset %%s %%C(green)(%%cr) %%C(blue)<%%an>%%Creset' --abbrev-commit
    s = status
[url \"https://github.com/\"]
    insteadOf = gh:
" "$name" "$email" > $DOTFILES/git/gitconfig
    echo "${BOLD}Creating Sympolic link to gitconfig$RESET"
    ln -s $DOTFILES/git/gitconfig ~/.gitconfig
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  ManageFilesAndLinks
#   DESCRIPTION:  Create symbolic links to your ~/dotfiles directory
#    PARAMETERS:  None
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
ManageFilesAndLinks()
{
    ln -s $DOTFILES/vim ~/.vim

    echo "$RESET${BOLD}Creating Diectory in:$BLUE $VIMDIR$RESET"
    mkdir -p $VIMDIR/colors

    mkdir -p $VIMDIR/bundle/nerdtree/nerdtree_plugin
    ln -s $VIMDIR/patches/NerdTreePatch.vim $VIMDIR/bundle/nerdtree/nerdtree_plugin/NerdTreePatch.vim 

    #User PATH location
    mkdir -p $LOCALBIN
    ln -s $DOTFILES/local/bin/git_diff_wrapper.sh $LOCALBIN/git_diff_wrapper.sh

    echo "${BOLD}Creating Symbolic links for .vimrc, bash_alises, and .tmuxrcx$RESET"
    ln -s $DOTFILES/shell/shell_aliases ~/.bash_aliases
    ln -s $DOTFILES/shell/shell_aliases ~/.zsh_aliases
    ln -s $DOTFILES/shell/personal_aliases ~/.personal_aliases
    ln -s $DOTFILES/shell/personal_aliases ~/.personal_aliases
    ln -s $DOTFILES/tmux/tmux.conf ~/.tmux.conf
    ln -s $DOTFILES/vim/vimrc ~/.vimrc

    echo "${BOLD}Downloading Colors wombat256mod.vim$RESET"
    wget -O $VIMDIR/colors/wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400

    if [ "$ZSH" = true ]; then
        # Set Zsh
        echo "${BOLD}Appending Aliases file to ~/.zshrc $RESET"
        echo "source ~/.zsh_aliases" >> ~/.zshrc
    fi

    echo ""
}



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  main
#   DESCRIPTION:  This is the main driver function.
#    PARAMETERS:  Optional parameters: --help, --administrator, --remove
#       RETURNS:  Success or Error
#-------------------------------------------------------------------------------
main()
{
#Run Init
    Init "$@"     # Remeber to pass the command line args $@
    Setup
    CheckOptional
    CheckDeps

    if [ "$ADMIN" = true ]; then
        AdminSetup
    fi

    GetUserInfo   # Get user information

    ManageFilesAndLinks   #Create Dirs Copy Files and Make Links

    #Install Powerline Fonts?
    read -n 1 -p  "${BOLD}Install$BLUE PowerLine Fonts$RESET$BOLD (Y/n): $GREEN" choice
    case "$choice" in
        n|N ) :;;
        y|Y|* ) InstallPowerlineFonts;;

    esac
    echo "$RESET"

    CreatePersonalTemplate
    CreateGitConfig

    if [ "$ZSH" = true ]; then
        echo "${BOLD}Downloading and installing: oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi

    vim +PlugInstall +qall #Installs the vim plugin system and updates all plugins

    echo ""
    echo "$BOLD${GREEN} $SCRIPTNAME $RESET$BOLD DONE: Enjoy a better$BLUE vim$RESET$BOLD experince.$RESET"
    echo ""
}

main "$@"     #remember to pass all command line args
