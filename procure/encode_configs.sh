#!/bin/bash

SOURCE_DIR="../configs"
TARGET_DIR="../configs/encoded"

mkdir -p "$TARGET_DIR"

# Loop through the .json files in the source directory
for file in "$SOURCE_DIR"/*.json; do
    # Extract the base name of the file
    base_name=$(basename "$file" .json)

    # Encode the file and save it in the target directory
    base64 -i "$file" > "$TARGET_DIR/$base_name"
done