Intro
As an iOS developer, there might have been times when you found yourself on the hunt for a simple, effective way to manage build numbers with a custom format. If so, you’re not alone. In this article, we’ll explore how to automate the process of incrementing build numbers in Xcode, with a custom format based on date and counter. The goal is not only to set the CFBundleVersion, but also to update project settings, making your life as a developer that much easier.

The Challenge
A while back, I found myself in need of a method to manage build numbers based on a combination of date and counter. There were existing solutions, of course. The agvtool bump command, for instance, works well for a counter-based build number by simply adding +1 to the count. However, it fell short when it came to customising the format.

Likewise, PlistBuddy offered a way to change CFBundleVersion, but it lacked the capacity to alter project settings. It seemed I had hit a wall. But as it turns out, there was a solution just around the corner.

The Inspiration
The breakthrough came after reading a post by Trevor at theswift.dev. His article on using Xcode environment variables for automated incrementing of build numbers sparked an idea. The concept was simple but powerful: store the version and build number in the project file (more precisely, in project.pbxproj), then use $(CURRENT_PROJECT_VERSION) for the build number and $(MARKETING_VERSION) for the version in both each target’s build settings and Info.plist file.

This approach opened up the possibility of setting a custom format for the build number, which could then be propagated throughout the Xcode project. It was the missing piece of the puzzle I had been searching for.

The Custom Format
With this newfound insight, I set out to implement a custom build number format of YYYYMMDDC, where C is a counter for a given day (for example, 202306216 would be the 6th build on that day). Here’s how you can do it too.

Step 1: Creating a Configuration File
First off, you’ll need to create a new configuration file, *.xcconfig, in your project. In this file, you need to set two key-value pairs: VERSION and BUILD_NUMBER. Here’s what it should look like:


//
//  Config.xcconfig
//  carbonwatchuk
//
//  Created by Mateusz Siatrak on 21/06/2023.
//

// Configuration settings file format documentation can be found at:
// https://help.apple.com/xcode/#/dev745c5c974

VERSION = 1.0.1
BUILD_NUMBER = 202306211
Step 2: Configuring Xcode to Use the Configuration File
For Xcode to use this new configuration file, you need to set it for each of your configurations. You can do this under Project → Configurations → Based on Configuration File column.


Adding Config file to the project setting for each configuration
Next, set Current Project Verision to $(BUILD_NUMBER) and Marketing Version to $(VERSION). This ensures that Xcode knows which build number and version to use for the project.


setting up $(CURRENT_PROJECT_VERSION) to $(BUILD_NUMBER)

setting up $(MARKETING_VERSION) to $(VERSION)
Step 3: Automating the Build Number Update
The final step is to write a script that updates the BUILD_NUMBER every time you run a build or when you’re archiving for TestFlight. You can achieve this by adding a pre-build action for each of your schemes that calls this script. You have two options: write the script directly in the form provided, or create a separate script file, attach it to the Xcode project, and call the script in the pre-build action.

I chose the latter option. This allows me to modify the script directly from the Xcode editor, without diving into scheme settings. Here’s my version.sh script:


#!/bin/bash
# This script is designed to increment the build number consistently across all
# targets.

# Navigating to the 'carbonwatchuk' directory inside the source root.
cd "$SRCROOT/$PRODUCT_NAME"

# Get the current date in the format "YYYYMMDD".
current_date=$(date "+%Y%m%d")

# Parse the 'Config.xcconfig' file to retrieve the previous build number. 
# The 'awk' command is used to find the line containing "BUILD_NUMBER"
# and the 'tr' command is used to remove any spaces.
previous_build_number=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' Config.xcconfig | tr -d ' ')

# Extract the date part and the counter part from the previous build number.
previous_date="${previous_build_number:0:8}"
counter="${previous_build_number:8}"

# If the current date matches the date from the previous build number, 
# increment the counter. Otherwise, reset the counter to 1.
new_counter=$((current_date == previous_date ? counter + 1 : 1))

# Combine the current date and the new counter to create the new build number.
new_build_number="${current_date}${new_counter}"

# Use 'sed' command to replace the previous build number with the new build 
# number in the 'Config.xcconfig' file.
sed -i -e "/BUILD_NUMBER =/ s/= .*/= $new_build_number/" Config.xcconfig

# Remove the backup file created by 'sed' command.
rm -f Config.xcconfig-e
And this is how I call it:


Setting up pre-action for Build in schema
cd "$SRCROOT/$PRODUCT_NAME"

source version.sh
Marketing Version Control
Now, if you want to increase your marketing version number, all you have to do is change the value assigned to VERSION in the config file. This keeps version control simple and straightforward, just edit one file — no more going to project settings.

Summary
Managing build numbers in Xcode can be a tricky business, especially when you want to use a custom format. However, with the right approach, it’s possible to automate the process with a high degree of customisability. By storing version numbers in a config file and using a build script to increment them, you can maintain a consistent, customised build number across your project.

This method not only simplifies the management of your build numbers but also ensures that all relevant settings in your project are updated as well. So give it a try, and see the difference it can make in your Xcode project management.