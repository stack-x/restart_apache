#!/bin/bash

# The first user passed parameter
# MUST match the name of a virtual-host
CONFIG="$1"

# The second user passed parameter
# MUST match the name of a service dirctive
COMMAND="$2"

# Does the first parameter an actual virtual-host
FILEMATCH=false

# A concatenated string of virtual hosts
VALID_VHOSTS=''

# Grab a list of all virtual-host files
VHOSTS=/etc/apache2/sites-available/*.conf

# Did the user provide the required number of paramters?
if [ $# -ne 2 ]
then
    echo "ERROR: $0 requires two paramters {virtual-host} {restart|reload}"
    exit 1
fi

# Loop through the all files in the sites-avaliable directory
for FILENAME in $VHOSTS
do

  # Add each virtual-host in the sites-available directory to 
  # the VHOSTS string. This will provide user feedback if there
  # is an error
  if [ -z  "$VALID_VHOSTS" ]
    then
      VALID_VHOSTS="${FILENAME:29:-5}"
    else
      VALID_VHOSTS="${VALID_VHOSTS}|${FILENAME:29:-5}"
    fi

  if [ "$FILENAME" == "/etc/apache2/sites-available/${CONFIG}.conf" ]
  then
    # Set filematch to true if one of those files matches an actual
    # virtual-host configuration and break the loop
    FILEMATCH=true
    break
  fi
done

# I we could match the frist argument to a virtual-hosts preset the user with an error
if [ $FILEMATCH  == false ]
then
    echo "ERROR: Invalid ${CONFIG} is NOT a valid virtual-host file {$VALID_VHOSTS}"
    exit 1
fi

# If the second argument matches either reload or restart execute the program
# as intended
if [ "$COMMAND" == "reload" ] || [ "$COMMAND" == "restart" ]
then
    # Move the current execution state to the proper directory
    cd /etc/apache2/sites-available

    # Disable a vhost configuration
    sudo a2dissite "$CONFIG"
    sudo service apache2 "$COMMAND"

    # Enable a vhost configuration
    sudo a2ensite "$CONFIG"
    sudo service apache2 "$COMMAND"
else
# Otherwise present the user with an error.
    echo "ERROR: $COMMAND is NOT a valid service command {restart|reload}"
    exit 1
fi


