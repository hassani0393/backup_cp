#!/bin/bash

#
# Script Name: /backup_cp/script/backup_cp.sh
#
# Author: Mostafa Hassani
#
# Description: The following script takes a source directory and a destination directory on the same or different servers as arguments and 
# uses Rsync program to create a backup of the files of the source directory, in the destination directory.
#
# Logging: It saves operation logs at $OPlogs and error logs at $ERRlogs directories.
#
# 
#
# If no option is given, The script will run with values sourced from the config
# file, running optionLess function.
#



# importing variables and directories from the config file.
. backup_cp.conf



# function definitions - start



rsyncVerify() {      # this function will verify the installation of Rsync program, otherwise print an error and exit

    command -v rsync >/dev/null 2>&1

    if [[ $? -ne 0 ]]
    then   
        echo "Rsync is not installed. Abort."
        exit 1
    fi
}


srcVerify() {       # this function will verify if the source directory exists and is readable
    
    if [ ! -r /$srcDir ]
    then
        echo "The $srcDir directory does not exist or is not readable."
        exit 1  
    fi
}


optionParserSwitcher() {    # this function will pars the option and will call the appropriate function, or 
                            # in case of invalid option, will show an error message and exit the program
    if [ -z "$1" ]
        then
            optionLess      # the case with no option, which will call optionLess function
        else
            case "$1" in
            -a) takeAddress     ;;  # the case with option -a , which will call takeAddress function
            * ) echo "\"$1\" is not a proper option. Use no options to take value from backup_cp.conf or use \"-a\" to use with address or use \"-s\" to use with socket."
                exit 128    ;;
            esac

    fi

}


optionLess () {     # this funciton will take the variable values, sourced from backup_cp.conf

    srcVerify
    rsync -av $srcDir/ $destUser@$destIP:/$destInput

}



takeAddress () {    # this function will take the format: backup_cp.sh -a [srcDir] [destUser]@$destIP:/$destInput

    shift   # gets rid of the option argument.
    
    srcDir=$1      # takes the next argument as source directory on the local system
    srcVerify    # checks if the source directory exists

    destInput=$2
    rsync -av $srcDir/ $destInput
}



# function definitions - end


# MAIN the program starts running from here.

exec 2>$ERRlogs/"$(date +"%F-%T").log" #redirecting all errors to the ERRlogs directory.

rsyncVerify

optionParserSwitcher



#rsync -rv $srcDir/ $destDir
