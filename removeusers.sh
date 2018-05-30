#!/bin/bash

# iterate through the /Users directory and remove all users except for local admins and shared folder
# --------- jdmartin@wsu.edu - 05/30/2018 ---------------
for username in `ls /Users | grep -v admin | grep -v anotheradmin | grep -v Shared | grep -v Library | grep -v .localized`
do
    if [[ $username == `ls -l /dev/console | awk '{print $3}'` ]]; then
        echo "Skipping user: $username (current user)"
    else
        echo "Removing user: $username"

        # Remove the account - optional
        #dscl . delete /Users/$username

        # Remove the user directory
        rm -rf /Users/$username
    fi
done
