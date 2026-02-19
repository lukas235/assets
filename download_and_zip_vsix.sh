#!/bin/bash

# This script downloads a Visual Studio Code extension VSIX file
# and compresses it into a .7z archive.
#
# Usage: ./download_and_zip_vsix.sh <publisher.extension_name>
#
# Example:
# ./download_and_zip_vsix.sh ms-vscode.cpptools

# --- Configuration ---
# Set to 1 to keep the downloaded .vsix file
DEBUG=0

# --- Script ---
set -e # Exit immediately if a command exits with a non-zero status.

# Check for required tools (curl, 7z)
for tool in curl 7z; do
  if ! command -v "$tool" &> /dev/null; then
    echo "Error: Required tool '$tool' is not installed. Please install it and try again." >&2
    exit 1
  fi
done

# Validate input arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <publisher.extension_name>" >&2
  echo "Example: $0 ms-vscode.cpptools" >&2
  exit 1
fi

# Assign arguments to variables
FULL_EXTENSION_NAME="$1"
PUBLISHER=$(echo "$FULL_EXTENSION_NAME" | cut -d. -f1)
EXTENSION_NAME=$(echo "$FULL_EXTENSION_NAME" | cut -d. -f2-)

# Define file and directory names
VSIX_FILE="${FULL_EXTENSION_NAME}.vsix"
ARCHIVE_NAME="${FULL_EXTENSION_NAME}.7z"
DOWNLOAD_URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${PUBLISHER}/vsextensions/${EXTENSION_NAME}/latest/vspackage"

# --- Main Execution ---

echo "Downloading VSIX for '${FULL_EXTENSION_NAME}'..."
# Use curl to download the file, -L to follow redirects, -f to fail on server errors, -o to specify output file
if ! curl -Lfo "$VSIX_FILE" "$DOWNLOAD_URL"; then
    echo "Error: Download failed. Please check the publisher and extension name." >&2
    # No need to delete VSIX_FILE, as curl with -f won't create it on failure
    exit 1
fi
echo "Download successful."

echo "Creating 7z archive '${ARCHIVE_NAME}'..."
# Create the 7z archive from the downloaded VSIX file.
if ! 7z a -ms=on -p123 -aoa "${ARCHIVE_NAME}" "$VSIX_FILE"; then
    echo "Error: Failed to create 7z archive." >&2
else
    echo "Successfully created '${ARCHIVE_NAME}'."
fi

# --- Cleanup ---
if [ "$DEBUG" -eq 0 ]; then
    echo "Cleaning up intermediate files..."
    rm -f "$VSIX_FILE"
fi

echo "Done."
