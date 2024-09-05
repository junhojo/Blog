#!/bin/bash
# This script is designed to increment the build number consistently across all
# targets with the counter starting at 1000.

# Navigating to the 'carbonwatchuk' directory inside the source root.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

#cd "$SRCROOT/$PRODUCT_NAME"

# Get the current date in the format "YYYYMMDD".
current_date=$(date "+%Y%m%d")
printf "1 %s\n" "$current_date"

# Parse the 'Config.xcconfig' file to retrieve the previous build number.
# The 'awk' command is used to find the line containing "BUILD_NUMBER"
# and the 'tr' command is used to remove any spaces.
previous_build_number=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' Config.xcconfig | tr -d ' ')
printf "2 %s\n" "$previous_build_number"

# Extract the date part and the counter part from the previous build number.
previous_date="${previous_build_number:0:8}"
counter="${previous_build_number:8}"

# If the current date matches the date from the previous build number, 
# increment the counter. Otherwise, reset the counter to 1000.
new_counter=$((current_date == previous_date ? counter + 1 : 1000))
printf "3 %s\n" "$new_counter"

# Combine the current date and the new counter to create the new build number.
new_build_number="${current_date}$(printf "%04d" "$new_counter")"
printf "4 %s\n" "$new_build_number"

# Use 'sed' command to replace the previous build number with the new build 
# number in the 'Config.xcconfig' file.
sed -i -e "/BUILD_NUMBER [[:space:]]*=[[:space:]]*/ s/= .*/= $new_build_number/" Config.xcconfig
printf "5 %s\n" "Build number updated in the 'Config.xcconfig' file"

# Remove the backup file created by 'sed' command.
rm -f Config.xcconfig-e
printf "6 %s\n" "Backup file removed"
