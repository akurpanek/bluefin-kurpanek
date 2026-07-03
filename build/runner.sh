#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

###############################################################################
# Central Build Runner Script for Custom Bluefin/Finpilot Images
###############################################################################
# This script automatically discovers and executes all numbered build scripts
# within the build directory in correct numerical/alphabetical order.
#
# To use this runner:
# 1. Rename this file to remove the .example extension: runner.sh
# 2. Add individual install scripts using the schema: [0-9]*-*.sh
#
# IMPORTANT CONVENTIONS (from @ublue-os/bluefin):
# - Ensures a single, clean entry point within the Containerfile
# - Automatically handles script paths and validation before execution
# - Scripts will be executed sequentially (e.g., 10-..., 20-..., 30-...)
# - Individual scripts must handle their own repository cleanup
###############################################################################

# Determine the absolute directory where this runner and other scripts reside
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

echo "======================================================================="
echo "Starting Central Build Runner in: $SCRIPT_DIR"
echo "======================================================================="

# Find all matching scripts, sort them numerically/alphabetically, and loop
# Using find + sort to safely handle potential empty directories or spaces
while rsync_loop='' read -r script; do
    # Skip if no matching files were found (glob expansion safety)
    [[ -e "$script" ]] || continue
    
    script_name=$(basename "$script")
    
    echo "-----------------------------------------------------------------------"
    echo "Running build stage: $script_name"
    echo "-----------------------------------------------------------------------"
    
    # Ensure the script is actually executable before running it
    if [ -x "$script" ]; then
        "$script"
        echo "$script_name completed successfully"
    else
        echo "ERROR: $script_name is not executable! Skipping."
        echo "Fix this by running: chmod +x build/$script_name"
        exit 1
    fi

done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "[0-9]*-*.sh" | sort)

echo "======================================================================="
echo "All discovered build scripts executed successfully!"
echo "======================================================================="
