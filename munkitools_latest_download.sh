#!/bin/bash

# Needs to be run as root
# Uses curl to determine link to latest munkitools download from github then downloads and installs it. 
# Configures munki to point to your local munki repo server and then creates a file that munki will look for 
# on reboot to check and install necessary software.
# ------- jdmartin@wsu.edu - 05/30/2018 --------

# Initialize variables
TEMP_DIR="$3/temp"
MUNKI_LATEST="https://github.com/munki/munki/releases/latest"

# create the temp directory
mkdir $TEMP_DIR

#Determine the URL to the latest Munki pkg
DOWNLOAD_PART="$(curl -I -s $MUNKI_LATEST | grep Location | awk -F: '{print $3}')" 
DOWNLOAD_PART=${DOWNLOAD_PART%$'\r'} #strip the carriage return '\r' character
DOWNLOAD_PAGE="https:${DOWNLOAD_PART}" 
URL_PART="$( curl -s -S ${DOWNLOAD_PAGE} | grep href | sed 's/.*href="//' | sed 's/".*//' | grep pkg )"
FILE_NAME=$(echo "$URL_PART" | sed 's/.*\///')
FINAL_URL="https://github.com${URL_PART}"

# download the installation pkg file to the aadmin users directory
curl -L -o $TEMP_DIR/$FILE_NAME -k $FINAL_URL
#curl -L -O -k $FINAL_URL

#run the installer
installer -pkg $TEMP_DIR/$FILE_NAME -target /

#update the Munki configuration
defaults write $3/Library/Preferences/ManagedInstalls SoftwareRepoURL "http://<your server ip>/munki_repo"
#defaults write $3/Library/Preferences/ManagedInstalls AdditionalHttpHeaders -array "Authorization: Basic <your base64 encoded password>"

# tell Munki to check and install updates at next reboot
touch $3/Users/Shared/.com.googlecode.munki.checkandinstallatstartup

#delete the temp dir
rm -r $TEMP_DIR

reboot

exit 0