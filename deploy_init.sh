#!/bin/bash

# Script to copy files customised files to its destination
# This script will be run multiple times 
# WARNING : Only add task to this script when SAFE to be re-run multiple times ( ie files overwritten ) 

repo=https://github.com/rwahyudi/deploy_initfiles.git
tmp_dir=/tmp/deploy_initfiles/

#### -------- Sanity checks ---------- ####

# - Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# - Ensure -f is present ( to avoid accidental run )
if [ "$1" != "-f" ]
then
    echo "Usage : $0 -f"
    echo 
    echo " This script will run standard deployment tasks and OVERWRITE changes on local server with the one specified on the repository"
    echo " Use -f argument to run"
    echo
    exit 1
fi

# - Ensure git is installed
command -v git >/dev/null 2>&1 || { echo >&2 "Git is not installed.  Aborting."; exit 1; }

# - Ensure clean start
rm -rf "$tmp_dir"

#### -------- Clone Repo ---------- ####
git clone "$repo" "$tmp_dir"

if [ $? -ne 0 ]
then
    echo " Issue with cloning repo. Aborting"
    exit 1
fi

###################################### 
####          TASKS 
######################################

# -- Copy custom profile
rsync -av $tmp_dir/custom-profile.sh /etc/profile.d/custom-profile.sh

# -- Copy dotfiles 
rsync -av $tmp_dir/.[^.]* /root/ --exclude=.git

# -- Copy bin files
mkdir -p /root/bin/
rsync -avr $tmp_dir/bin/ /root/bin/















