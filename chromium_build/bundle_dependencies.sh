#!/bin/bash

# Check if user has provided an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path_to_executable>"
  exit 1
fi

# Check if the provided path is an executable
if [ ! -x "$1" ]; then
  echo "Error: '$1' is not an executable or doesn't exist."
  exit 1
fi

# Create a temporary directory to store the actual files
temp_dir=$(mktemp -d)

# Use ldd to list dependencies and resolve symlinks
ldd "$1" | awk '/=>/ { print $1 " " $3 }' | while read -r dep_name dep_path; do
  # Resolve the symlink to the actual file
  actual_file=$(readlink -f "$dep_path")

  # Copy the actual file to the temporary directory, but rename it
  cp "$actual_file" "$temp_dir/$dep_name"
done

# Create a tar archive with the original executable and resolved dependencies
tar -czvf dependencies.tar.gz -C "$temp_dir" .

# Clean up the temporary directory
rm -rf "$temp_dir"

echo "Successfully created dependencies.tar.gz with resolved dependencies."
