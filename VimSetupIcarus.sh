#!/bin/bash

#Writen by John Warnes
#Based on vimrc setup from Hugo Valle
# Modify on May-29-2017 by Hugo V. to fit Icarus regular user accounts

#echo "arg: $@"    # Debug

#Directory Setup
DOTFILES=~/dotfiles
VIMDIR=~/.vim

#Global Vars (Manualy Set)
SCRIPTNAME="WSU JW-Custom VIM IDE"
#PKGS="git exuberant-ctags vim python3-doc"
PKGS="git vim"

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


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  PrintHelp
#   DESCRIPTION:  Help Function for script. Invoked with --help
#    PARAMETERS:  None
#       RETURNS:  None
#-------------------------------------------------------------------------------
PrintHelp()
{
    echo "$RESET${BOLD}useage: $0 [--administrator] [--remove]$RESET"
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

    #links
    rm -rf ~/.vimrc ~/.bash_aliases ~/.gitconfig
    
    #directorys
    rm -rf $VIMDIR
    
    #if .vim is syslink
    unlink ~/.vim

    echo "${BOLD}Remove Complete$RESET"     
    echo ""
    exit -1
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Init
#   DESCRIPTION:  Iinitailzation of script. Color setup. Folder configuration.
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
        --remove) REMOVE=true;;
        -h | --help) PrintHelp;; *) :;;
                esac; shift;
    done

    if [ "$REMOVE" = true ]; then
        Remove
    fi
   
    clear
    echo "${BOLD}Installing$GREEN $SCRIPTNAME $RESET$BOLD(vim/git)$RESET"
    echo ""  
    
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
        fi
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
" "$name" "$email" > $DOTFILES/git/gitconfig 
    echo "${BOLD}Creating Sympolic link to gitconfig$RESET"
    ln -s $DOTFILES/git/gitconfig ~/.gitconfig
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

    echo "${BOLD}Creating Symbolic links for .vimrc and .tmuxrcx$RESET"
    ln -s $DOTFILES/bash/bash_aliases ~/.bash_aliases
    ln -s $DOTFILES/bash/bashrc ~/.bashrc
    
    ln -s $DOTFILES/vim/vimrc ~/.vimrc
    ln -s $DOTFILES/vim/python-mode.template $VIMDIR/templates/python-mode.template

    echo "${BOLD}Downloading Colors wombat256mod.vim$RESET"
    wget -O $VIMDIR/colors/wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400

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
    CheckDeps

    GetUserInfo   # Get user information

    ManageFilesAndLinks   #Create Dirs Copy Files and Make Links

    CreatePersonalTemplate
    CreateGitConfig

    vim +PlugInstall +qall #Installs the vim plugin system and updates all plugins

    echo ""
    echo "$BOLD${GREEN} $SCRIPTNAME $RESET$BOLD DONE: Enjoy a better$BLUE vim$RESET$BOLD experince.$RESET"
    echo ""
}

main "$@"     #remember to pass all command line args
