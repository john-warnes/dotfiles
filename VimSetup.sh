#!/bin/bash

#Writen by John Warnes
#Based on vimrc setup from Hugo Valle

#echo "arg: $@"    # Debug

#Directory Setup
#DOTFILES=~/dotfiles
#VIMDIR=$DOTFILES/vim

DOTFILES=~/.vim
VIMDIR=$DOTFILES

#Global Vars (Manualy Set)
SCRIPTNAME="WSU JW-Custom VIM IDE"
PKGS="git exuberant-ctags vim python3-doc"
OSXPKGS="git ctags vim python3"

# ID ---> https://github.com/zyga/os-release-zoo 
SUPPORTEDDISTROS="ubuntu, linuxmint, debian, elementary OS, neon, peppermint, Zorin OS"

#Global Vars (Auto Set - Change will have BAD effects)
REMOVE=false
FILENAME=$0
ADMIN=false
WSU=false
TMUX=false
ZSH=false
OS=""


PrintHelp()
{
    echo "$RESET${BOLD}useage: $0 [--administrator] [--remove]$RESET"
    exit -1
}



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

    #links
    rm -rf ~/.vimrc ~/.bash_aliases ~/.tmux.conf ~/.gitconfig
    
    #directorys
    rm -rf $VIMDIR $DOTFILES
    
    #if .vim is syslink
    unlink ~/.vim

    echo "${BOLD}Remove Complete$RESET"     
    echo ""
    exit -1
}



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
        -h | --help) PrintHelp;;
        *) :;;
                esac; shift;
    done

    if [ "$REMOVE" = true ]; then
        Remove
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
            echo "$BOLD${RED}ERROR!$RESET$BOLD Undetect Linux: $ID $RESET"
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
  
            read -n 1 -p "$RESET${BOLD}Are you installing while on a$BLUE WSU campus$RESET netwokr (needs IPv6 fix)$RESET$BOLD (Y/n): $GREEN" choice
            echo "$RESET"
            case "$choice" in
                y|Y ) WSU=true;;
                n|N ) WSU=false;;
                * ) WSU=true;;
            esac

        fi

    elif [ "$OS" == "OSX" ]; then

        echo "${BOLD}OSX Detected $RESET"

        if which brew 2> /dev/null; then
            echo "$BOLD${YELLOW}Note!$RESET$BOLD Missing Packages will installed using BREW"
        else
            echo ""
            echo "$BOLD${RED}ERROR!$RESET$BOLD OSX:$BLUE HomeBrew (https://brew.sh/)$RESET$BOLD is required."
            echo ""
            exit -1
        fi

    fi

    echo ""
}



CheckDeps() 
{
    echo ""
    echo "${BOLD}Checking for Requered Packages:$RESET"
    ERRORFLAG=false

    if [ "$OS" == "LINUX" ]; then

        for PKG in $PKGS; do

            if [ "$(dpkg-query -f='${Status}\n' -W $PKG | awk '{print $3;}')" = "installed" ]; then
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
        echo "$BOLD${RED}ERROR$RESET$BOLD Required Packages Missing: RUN:$BLUE \"$FILENAME --administrator\"$RESET$BOLD to fix $RESET"
        echo ""
        if [ "$ADMIN" = true ]; then 
            return
        else
            exit
        fi
    fi   
    echo ""
}



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
        y|Y|* ) PKGS+=" zsh";OSXPKGS+=" zsh"; TMUX=true;;
    esac
}



#Only needed once on each computer
AdminSetup() 
{
    echo "$BLUE${BOLD}Admin Setup$RESET$BOLD ($OS)"

    if [ $OS == 'LINUX' ]; then

        if [ 1 -eq "$(echo "${VERSION} < 16.04" | bc)" ]; then
            echo "$RESET${RED}ERROR!$RESET$BOLD$BLUE Dectect Verion($VERSION) Required: >16.04$RESET"
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



getUserInfo()
{
    read -p "$RESET${BOLD}Enter your$BLUE Full Name$RESET$BOLD Ex\"John Doe\": $GREEN" name
    read -p "$RESET${BOLD}Enter your$BLUE Email Address$RESET$BOLD Ex\"JohnD@mail.weber.edu\": $GREEN" email
    read -p "$RESET${BOLD}Enter your$BLUE Oganization$RESET$BOLD Ex\"WSU\": $GREEN" org
    read -p "$RESET${BOLD}Enter your$BLUE Company$RESET$BOLD Ex\"WSU\": $GREEN" com
}



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
   
    #echo "$BOLD$BLUE"
    #printf "Powerline Fonts$RESET$BOLD Installed 
    #Change the font of Terminal to one supporting powerline.
    #
    #On Ubuntu 
    #Click [EDIT] > [Profile Preferences]
    #Check the Custom Font option and click on the font name
    #Select a font with the word \"Powerline\" in the name
    #Recommend: DejaVu Sans Mono for Powerline Book"
    #echo ""
    #read -n 1 -p "$BOLD$GREENPress any key to continue...$RESET" -n1 -s
    #echo "$RESET"
}



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
[help]
autocorrect = 1
[color]
ui = auto
[push]
default = matching
" "$name" "$email" > $VIMDIR/gitconfig 
    echo "${BOLD}Creating Sympolic link to gitconfig$RESET"
    ln -s $VIMDIR/gitconfig ~/.gitconfig
}



CreateTmuxAliasZsh()
{
    echo "${BOLD}Creating Tmux alaises:$BLUE ~/.oh-my-zsh/lib/alias.zsh$RESET"

    mkkdir -p ~./.oh-my-zsh/lib/

printf "
#aliases for Tmux
alias tmux='tmux -2'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

#conveience aliases for editing configs
alias ev='vim ~/.vimrc'
alias et='vim ~/.tmux.conf'
alias ez='vim ~/.zshrc'

#user alias here
" > ~/.oh-my-zsh/lib/alias.zsh

    echo "${BOLD}Appending Alais file to .zshrc$RESET"
    echo "source ~/.oh-my-zsh/lib/alias.zsh" >> ~/.zshrc
}



ManageFilesAndLinks()
{

    if [ "$VIMDIR" != "~/.vim" ]; then    
        mkdir -p $VIMDIR
        ln -s $VIMDIR ~/.vim
    fi

    echo "$RESET${BOLD}Creating Diectory in:$BLUE $VIMDIR$RESET"
    mkdir -p $VIMDIR/colors
    mkdir -p $VIMDIR/templates
    mkdir -p $DOTFILES


    echo "${BOLD}Coping vimrc, tmux, and Python-mode.template $RESET"
    cp bash_aliases $DOTFILES/bash_aliases
    cp vimrc $DOTFILES/vimrc
    cp tmux.conf $DOTFILES/tmux.conf
    cp python-mode.template $VIMDIR/templates/python-mode.template

    echo "${BOLD}Creating Symbolic links for .vimrc and .tmuxrcx$RESET"
    ln -s $DOTFILES/bash_aliases ~/.bash_aliases
    ln -s $DOTFILES/tmux.conf ~/.tmux.conf
    ln -s $DOTFILES/vimrc ~/.vimrc

    echo "${BOLD}Downloading Colors wombat256mod.vim$RESET"
    wget -O $VIMDIR/colors/wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400

    echo ""
}




main()
{
    #MAIN START HERE!

    #Run Init
    Init "$@"     # Remeber to pass the command line args $@ 
    Setup
    CheckDeps

    if [ "$ADMIN" = true ]; then
        AdminSetup
    fi

    getUserInfo   # Get user information

    ManageFilesAndLinks   #Create Dirs Copy Files and Make Links

    #Install Powerline Fonts?
    read -n 1 -p  "${BOLD}Install$BLUE PowerLine Fonts$RESET$BOLD (Y/n): $GREEN" choice
    case "$choice" in 
        y|Y ) InstallPowerlineFonts;;
        n|N ) :;;
        * ) InstallPowerlineFonts;;

    esac
    echo "$RESET"

    CreatePersonalTemplate
    CreateGitConfig

    if [ "$ZSH" = true ]; then
        echo "${BOLD}Downloading and installing: oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"    
        CreateTmuxAliasZsh
    fi

    vim +PlugInstall +qall #Installs the vim plugin system and updates all plugins

    echo ""
    echo "$BOLD${GREEN} $SCRIPTNAME $RESET$BOLD DONE: Enjoy a better$BLUE vim$RESET$BOLD experince.$RESET"
    echo ""
}

main "$@"     #remember to pass all command line args
