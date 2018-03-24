#!/bin/bash

CONFIG="$1"
COMMAND="$2"
FILEMATCH=false;

# Grab a list of all virtual-host files
VHOSTS=/etc/apache2/sites-available/*.conf

if [ $# -ne 2 ]
then
    echo "ERROR: $0 requires two paramters {virtual-host} {restart|reload}"
    exit 1
fi

for FILENAME in $VHOSTS
do

  echo ${FILENAME:29:-5}

  if [ "$FILENAME" == "/etc/apache2/sites-available/${CONFIG}.conf" ]
  then
    FILEMATCH=true
    break
  fi
done

exit 1

if [ $FILEMATCH  == false ]
then
    echo "ERROR: Invalid ${CONFIG} is NOT a valid virtual-host file"
    exit 1
fi

# reload is allowed
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
    echo "ERROR: $COMMAND is NOT a valid service command {restart|reload}"
    exit 1
fi


