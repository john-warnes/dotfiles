#!/bin/bash

#name of this command
COMMAND="ALS_mount"

#the directory the command was called from .. aka the working directory
STARTDIR=$(pwd)

#DIR where the script is
SCRIPTDIR="$(dirname $0)"

#prints to consol if verbose is on
function log () {
	if [ $VERBOSE ];  then
		echo "$@"
	fi

}

#Script version
VERSION=0.2a

#prints the current script verion
function version () {
	echo "Current version is $VERSION"
}

#print usage
function usage () {
	echo "Usage: $COMMAND [OPTION]..."
	echo ''
	echo 'Mandatory arguments to long options are mandatory for short options too.'
	echo '  -u, --Unmount                Remove Custom Mounts'
	echo ' '
	echo '  -v, --verbose                explain what is being done'
	echo '  -h, --help                   display this help and exit'
	echo '  --version                    output version information and exit'
	echo ''
	echo 'By default all custom mount points are mounted'
}

#############################################
## STARTING MAIN SCRIPT (end of functions) ##
#############################################

#while there are more peramaters to processes continue processing them
while [ "$1" != "" ]; do

	#use a cast to processes each peramater
    case $1 in

        -u | --Unmount )    		UNMOUNT=1 ; log "Option selected '--Nosort' do no sorting" ;;

	#Debug and help
        -v | --verbose )     	VERBOSE=1 ; log "Option selected '--verbose' explain what is being done" ;;
        --version )				version ; exit ;;
        -h | --help )           usage ; exit ;;
        * )                     usage ; exit 1 ;;

	#close case
    esac

	#shift command line arguments
    shift

#end of loop
done

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi


if [ $UNMOUNT ] ; then

	sudo umount '/home/afterlifesol/Downloads/'
	sudo umount '/home/afterlifesol/Scripts/'
	sudo umount '/home/afterlifesol/VirtualBox VMs/'
	sudo umount '/home/afterlifesol/Desktop/'
	sudo umount '/home/afterlifesol/Documents/'

	exit
fi

sudo mount --bind '/media/afterlifesol/RedOne/afterlifesol/Downloads/' '/home/afterlifesol/Downloads/'
sudo mount --bind '/media/afterlifesol/RedOne/afterlifesol/Scripts/' '/home/afterlifesol/Scripts/'
sudo mount --bind '/media/afterlifesol/RedOne/afterlifesol/VirtualBox VMs/' '/home/afterlifesol/VirtualBox VMs/'
sudo mount --bind '/media/afterlifesol/RedOne/afterlifesol/Desktop/' '/home/afterlifesol/Desktop/'
sudo mount --bind '/media/afterlifesol/RedOne/afterlifesol/Documents/' '/home/afterlifesol/Documents/'

