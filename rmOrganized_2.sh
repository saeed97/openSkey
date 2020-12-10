#!/bin/bash
#
# $1 : Name of directory to be deleted
#
# This script can be called directly or by a run script

# Directory to be removed
inFile=$1

# Display status to screen
echo "Removing: $inFile"

# Remove
rm -f $inFile
