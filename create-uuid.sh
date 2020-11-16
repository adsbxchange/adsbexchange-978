#!/bin/bash

UUID_FILE="/boot/adsbx-uuid"

# Let's make sure the UUID tools are installed...
UUIDGEN=$(command -v uuidgen)
RV=$?

if [ $RV -ne 0 ]; then
    echo "Can't find uuidgen in path, trying to install uuidgen..."
    apt-get -y install uuid-runtime
    UUIDGEN=$(command -v uuidgen)
    RV=$?
    if [ $RV -ne 0 ]; then
        echo "Failed to install uuid-runtime package - need manual intervention!"
        sleep 60
        exit 10
    fi
fi

# Check for a (valid) UUID...
if [ -f $UUID_FILE ]; then
    UUID=$(cat $UUID_FILE)
    if ! [[ $UUID =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
        # Data in UUID file is invalid.  Regenerate it!
        echo "WARNING: Data in UUID file was invalid.  Regenerating UUID."
        rm -f $UUID_FILE
        UUID=$($UUIDGEN)
        echo New UUID: $UUID
        echo $UUID > $UUID_FILE
    else
        echo "Using existing valid UUID ($UUID) from $UUID_FILE"
    fi
else
    # not found generate uuid and save it
    echo "WARNING: No UUID file found, generating new UUID..."
    UUID=$($UUIDGEN)
    echo New UUID: $UUID
    echo $UUID > $UUID_FILE
fi

exit 0
