#!/usr/bin/env python3
# ============================================================================
# @file   DotSetup.py
# @brief  Install jIDE vim / nvim IDE
#
# @author John Warnes
#
# @internal
#      Created  Thursday, 04 January 2018
#     Modified  Wednesday, 14 March 2018
#     Revision  138
#
# @Copyright  Copyright (c) 2018, John Warnes
#
# ============================================================================

# Required Python3 and Pip3
#

import os
import platform
import subprocess

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


def main():
    '''
    Main
    '''
    collect_system_data()
    display_system_data()
    if not hasDependences():
        print("Error: Missing dependences.")
        quit()


if __name__ == "__main__":
    main()
    exit(0)
