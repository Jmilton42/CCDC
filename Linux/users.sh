#!/bin/bash

# Read passwords from passwords.csv
# If empty or DNE, throw error and exit
# Loop through every user in /etc/passwd
# If the user is root, skip
# If the user does not have a valid login shell, skip
# If the user does have a valid login shell, do the following:
# 	+ Check if the user is in passwords.csv, if not, print an error message and prompt to lock the user account
# 	+ If it is, then change the password to what is in passwords.csv
#	+ If the user is not an admin, then remove it from all of the administrative groups
# 	+ Set the users shell to rbash
