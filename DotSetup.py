#!/usr/bin/env python3
# ============================================================================
# @file   DotSetup.py
# @brief  Install jIDE vim / nvim IDE
#
# @author John Warnes
#
# @internal
#      Created  Thursday, 04 January 2018
#     Modified  Thursday, 22 March 2018
#     Revision  210
#
# @Copyright  Copyright (c) 2018, John Warnes
#
# ============================================================================

# Required Python3 and Pip3
#

import os
import platform
import subprocess

import argparse

from pkg_resources import parse_version

SETTINGS = {
    # Script
    'version': '3.0',

    # Directorys
    'dotfiles': '~/dotfiles',

    # Files
    'backup_file': '~/.jvimBackup',

    # vim
    'vim_recommended': '8.0',
    'vim_required': '7.4',

    'nvim_recommended': '0.2.0',
    }


SYSDATA = {}


def collect_system_data():
    '''
    Used to collect current system state
    '''
    global SYSDATA
    SYSDATA['script_dir'] = str(os.path.dirname(__file__))
    SYSDATA['script_file'] = str(__file__)
    SYSDATA['os_kind'] = os.name
    SYSDATA['os'] = platform.system()
    SYSDATA['os_release'] = platform.release()
    SYSDATA['os_dist'] = platform.linux_distribution()

    SYSDATA['vim_version'] = subprocess.check_output(
        "vim --version | head -1 | cut -d ' ' -f 5",
        shell=True).decode('ascii').strip()

    SYSDATA['nvim_version'] = subprocess.check_output(
        "nvim --version | head -1 | cut -d ' ' -f 2",
        shell=True).decode('ascii').strip()[1:]
    # print(os.getcwd())  # Current DIR
    # os.chdir(current_dir)  # Chance DIR


def display_system_data():
    '''
    Display current system infromation
    '''
    print("== JVIM ", SETTINGS['version'], " ==")
    print(' Script File: ', SYSDATA['script_file'])
    print(' Script Directory: ', SYSDATA['script_dir'])
    print()
    print('-- OS --')
    print(' Kind: {}'.format(SYSDATA['os_kind']))
    print(' OS: {}'.format(SYSDATA['os']))
    print(' Release: {}'.format(SYSDATA['os_release']))
    print(' Dist: {}'.format(SYSDATA['os_dist']))
    print()
    print('-- Vim --')
    print(' Required Version: {:6}'.format(SETTINGS['vim_required']))
    print(' Recommended Version: {:6}'.format(SETTINGS['vim_recommended']))
    print(' Current Version: {:5}'.format(SYSDATA['vim_version']))
    print()
    print('-- Neovim --')
    print(' Recommended Version: {:6}'.format(SETTINGS['nvim_recommended']))
    print(' Current Version: {:5}'.format(SYSDATA['nvim_version']))
    print()


def hasDependences():
    print("== Checking Dependences ==")
    dependences = True;
    if parse_version(SETTINGS['vim_required']) > parse_version(SYSDATA['vim_version']):
        print(" :ERROR Vim version is below the required version")
        dependences = False;

        if parse_version(SETTINGS['vim_recommended']) > parse_version(SYSDATA['vim_version']):
            print(" Warring vim version is below the recommend version")
    else:
        print(" Vim version: OK")

    if parse_version(SETTINGS['nvim_recommended']) > parse_version(SYSDATA['nvim_version']):
        print(" Warring: Neovim version is below the recommend version")
    else:
        print(" Neovim version: OK")
    print()
    return dependences


def askUserData():
    global user
    user = {}

    print("=== User information ===")

    user["name"] = input("Enter your Full Name 'John Smith': ")
    if user["name"] == '':
        print("Error! Must enter a fist and last name. example: John Smith")
        quit()
    first, *mid, last = user["name"].split()

    user["user"] = input("Enter your username '{}{}' [Enter] for default: ".format(first[0].lower(), last.lower()))
    if user["user"] == '':
        user["user"] = first[0].lower() + last.lower()

    user["company"] = input("Enter your organization 'Weber State University' [Enter] for default: ")
    if user["company"] == '':
        user["company"] = 'Weber State University'

    user["org"] = input("Enter your organization 'Computer Science' [Enter] for default: ")
    if user["org"] == '':
        user["org"] = 'Computer Science'

    user["email"] = input("Enter your email '{}{}@mail.weber.edu' [Enter] for default: ".format(first.lower(), last.lower()))
    if user["email"] == '':
        user["email"] = first.lower() + last.lower() + '@mail.weber.edu'
    
    user["vim"] = input("Enter your default editor '{}' [Enter] for default: ".format('nvim'))
    if user["vim"] == '':
        user["vim"] = 'nvim'

    print("--- User ---")
    print(user)
    print("=== User information ===")

def createUserVim():
    f = open('vim/user.vim', 'w')
    f.write('let g:_NAME_    = {}\n'.format(user["name"]))
    f.write('let g:_USER_    = {}\n'.format(user["user"]))
    f.write('let g:_COMPANY_ = {}\n'.format(user["company"]))
    f.write('let g:_ORG_     = {}\n'.format(user["org"]))
    f.write('let g:_EMAIL_   = {}\n'.format(user["email"]))
    f.write('let g:_VIM_   = {}\n'.format(user["vim"]))
    f.close()

def createUserGit():
    f = open('git/gitconfig', 'w')
    f.write('''[user]
    name = {name}
    email = {email}
[core]
    editor = {vim}
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
    amend = !git log -n 1 --pretty=tformat:%s%n%n%b | git commit -F - --amend
    details = log -n1 -p --format=fuller
    logpretty = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%n%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset'
    logshort = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%h %d%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset' --abbrev-commit
    s = status
    arc = "!git tag archive/$1 $1 -m "Archived on: $(date '+%Y-%m-%dT%H:%M:%S%z')" && git branch -D $1 && git push origin -d $1 #"
    arcl = "!git tag | grep '^archive' #"
[url "https://github.com/"]
    insteadOf = gh:
'''.format(name=user["name"], email=user["email"], vim=user["vim"]) )
    f.close()

def install():
    askUserData()
    createUserVim()
    createUserGit()


def main():
    '''
    Main
    '''
    #process command line arguments
    parser = argparse.ArgumentParser()
    xorgroup = parser.add_mutually_exclusive_group()
    xorgroup.add_argument('-i','--install', help="Install Files", action="store_true", default=False)
    xorgroup.add_argument('-r','--remove', help="Remove Files", action="store_true", default=False)
    #parser.add_argument('-', help="Column to show", type=int, default=16, dest="col")
    args = parser.parse_args()

    print("-- Command line arguments ---")
    print(args)
    print("")

    collect_system_data()
    display_system_data()
    if not hasDependences():
        print("Error: Missing dependences.")
        quit()

    if args.install:
        install()
    elif args.remove:
        remove()



if __name__ == "__main__":
    main()
    exit(0)
