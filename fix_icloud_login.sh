#!/usr/bin/env bash

# Changing passwords on Mac computers is a difficult thing to manange
# This script attampts to fix any issues brought about by iCloud and keychain issues
#
# 10-19-2017 - jdmartin@wsu.edu

# Check an array to see if it contains an element
containsElement () {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}

#--------------------------------------------------------------------------
# For all user accounts:  **Except the admin account**
#
# 1. Log out all users from iCloud,
# 2. Change system preferences to lock the icloud preference pane
# 3. Remove the iCloud setup screen
# 4. Delete the login keychain
# 5. Attempt to delete the local items keychain folder
# 6. Fix any permissions issues that may come about
# 
#---------------------------------------------------------------------------

ls /Users/ | while read USERS ;
do
if [ "$USERS" != "admin" ] && [ "$USERS" != "anotheradmin" ]; then
	DISABLED_PREFS=$(/usr/libexec/PlistBuddy -c "print DisabledPreferencePanes:0" /Users/$USERS/Library/Preferences/com.apple.systempreferences.plist)
	if [ -d /Users/$USERS/Library/Preferences/ ]; then
		if [ -f /Users/$USERS/Library/Preferences/MobileMeAccounts.plist ]; then
			# sign the user out of iCloud
			rm /Users/$USERS/Library/Preferences/MobileMeAccounts.plist
		fi
		if [ ! -z "$DISABLED_PREFS" ]; then
			if ! containsElement "com.apple.preferences.icloud" "${DISABLED_PREFS[@]}"; then
				# disable the iCloud preferences pane
				defaults write /Users/$USERS/Library/Preferences/com.apple.systempreferences \
				DisabledPreferencePanes -array-add '<string>com.apple.preferences.icloud</string>'
			fi
		else
			# disable the iCloud preferences pane
			defaults write /Users/$USERS/Library/Preferences/com.apple.systempreferences \
			DisabledPreferencePanes -array-add '<string>com.apple.preferences.icloud</string>'
		fi
		# disable the login to iCloud nag box
		defaults write /Users/$USERS/Library/Preferences/com.apple.SetUpAssistant \
		DidSeeCloudSetup -bool TRUE

		# disable the Siri popup
		defaults write /Users/$USERS/Library/Preferences/com.apple.SetUpAssistant \
		DidSeeSiriSetup -bool TRUE
	fi
	if [ -f /Users/$USERS/Library/Keychains/login.keychain ]; then
		# Delete the login keychain < Sierra
		rm /Users/$USERS/Library/Keychains/login.keychain
	fi
	if [ -f /Users/$USERS/Library/Keychains/login.keychain-db ]; then
		# Delete the login keychain for Sierra+
		rm /Users/$USERS/Library/Keychains/login.keychain-db
	fi
	if [ -e /Users/$USERS/Library/Keychains/????????-????-????-????-???????????? ]; then
		# Delete the local items keychain
		rm -rf /Users/$USERS/Library/Keychains/????????-????-????-????-????????????
	fi
	# Set proper ownership of the files
	/usr/sbin/chown -R $USERS:staff /Users/$USERS/Library/Preferences/com.apple.systempreferences.plist
	/usr/sbin/chown -R $USERS:staff /Users/$USERS/Library/Preferences/com.apple.SetUpAssistant.plist
fi
done

killall cfprefsd

exit 0
