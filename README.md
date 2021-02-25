# Helper-Scripts
Helper scripts used in some iOS hacking

## findStringInMemory.js
Like the name says, find string in memory of application.

## skeleton.sh
Creates a skeleton frida script for intercepting method. You pass in the name of method you want to trace and it will create a frida script.

## prepare.sh
Bash script to patch the application with frida inside of it. You need to unzip the .ipa file and in the same directory where `Payload/` is located, copy the script. Also, in the same directory FridaGadget.dylib and embedded.mobileprovision need to be present. Script also expects the variable called BUNDLE which matches the bundle identifier used to create embedded.mobileprovision file.

![prepare.sh.png](Prepare)
