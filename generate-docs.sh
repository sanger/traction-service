#!/bin/bash

# This script builds the documentation for each directory in the 'documentation' directory.
# Note that the script builds sub-documentations, and not the main documentation in the root directory.
# For example, if the 'documentation' directory contains 'volume-tracking' and 'smrt-versioning' directories, this script will build the documentation for each of these directories.
# For the script to build the sub-documentation(s), the CI should build a 'docs' directory in the root directory of the repository (e.g. Yard CI action does that for us).

# Check if the 'documentation' directory exists
if [ -d "documentation" ]; then
    # Loop through each item in the 'documentation' directory
    for dir in documentation/*; do
        # Check if the item is a directory
        if [ -d "$dir" ]; then
            echo "Building documentation in $dir"
            
            # Build the documentation using mkdocs with the configuration file in the current directory
            mkdocs build -f $dir/mkdocs.yml
            
            # Get the base name of the directory (e.g., 'volume-tracking' from 'documentation/volume-tracking')
            target_doc=$(basename "$dir")
            
            # Define the target directory where the built documentation will be copied
            target_directory="doc/$target_doc"
            
            # Create the target directory if it doesn't exist
            mkdir -p $target_directory
            
            # Copy the built site to the target directory
            cp -r $dir/site/* $target_directory/
        fi
    done
else
    echo "The 'documentation' directory does not exist. Proceeding without building mkdocs documentation."
    exit 0
fi
