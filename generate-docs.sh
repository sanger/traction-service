for dir in documentation/*; do
if [ -d "$dir" ]; then
    echo "Building documentation in $dir"
    mkdocs build -f $dir/mkdocs.yml
    target_doc=$(basename "$dir")
    
    # Define the target directory where you want to copy the site content
    target_directory="doc/$target_doc"
    mkdir -p $target_directory
    cp -r $dir/site/* $target_directory/
fi
done