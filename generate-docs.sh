#!/bin/bash

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