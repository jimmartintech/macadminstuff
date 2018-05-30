#!/bin/bash

# configure remote login and remote management for local admin users
#
# *** run as root ***
#
# 05-29-2018 jdm

# enable remote login and add the local Administrators group to the access list
systemsetup -setremotelogin on
dseditgroup -o edit -a admin -t group com.apple.access_ssh

# Enable remote management for admin users
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu


exit 0
