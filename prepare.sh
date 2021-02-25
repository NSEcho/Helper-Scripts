#!/bin/bash

######################################################################
# You need to have FridaGadget.dylib and embedded.mobileprovision    #
# inside the directory where script is located. You also need to     #
# provide BUNDLE variable with bundle identifier used to create      #
# embedded.mobileprovision file.                                     #
######################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
END='\033[0m'

error() {
	message="$1"
	echo -e "${RED}${message}"
	echo -e "Exiting...${END}"
	exit 1
}

declare -a files=("FridaGadget.dylib" "embedded.mobileprovision")

check_files() {
	for file in "${files[@]}"; do
		if [ -f ${file} ]; then
			echo -e "${GREEN}[+] Found ${file}!${END}"
		else
			error "[-] File ${file} not found!"
		fi
	done
}

APP_NAME=$(find Payload/ -name "*.app")
EXECUTABLE=$(/usr/libexec/PlistBuddy "${APP_NAME}"/Info.plist -c "Print :CFBundleExecutable")

add_frida() {
	cp FridaGadget.dylib "${APP_NAME}"
	otool -L "${APP_NAME}/${EXECUTABLE}" | grep FridaGadget.dylib > /dev/null 2>&1; ec=$?
	if [ $ec -eq 0 ]; then
		echo -e "${GREEN}[+] Found LC_LOAD_DYLIB for FridaGadget!${END}"
	else
		insert_dylib --strip-codesig --inplace \
			@executable_path/FridaGadget.dylib \
			"${APP_NAME}/${EXECUTABLE}" > /dev/null 2>&1
	fi

	otool -l "${APP_NAME}/${EXECUTABLE}" | grep '@executable_path/\.' > /dev/null 2>&1; ec=$?
	if [ $ec -eq 0 ]; then
		echo -e "${GREEN}[+] Found correct entry @rpath!${END}"
	else
		install_name_tool -add_rpath @executable_path/. \
			"${APP_NAME}/${EXECUTABLE}" > /dev/null 2>&1
	fi
}

zip_application() {
	zip -qry patched.ipa Payload/ 
}

sign_app() {
	BUNDLE="${BUNDLE:=none}"
	if [ "${BUNDLE}" == "none" ]; then
		echo "Variable not found"
		error "[-] BUNDLE variable not found"
	fi
	applesign -m ./embedded.mobileprovision -b "${BUNDLE}" patched.ipa > /dev/null 2>&1
}

deploy() {
	rm -rf deploy/ 2> /dev/null
	mkdir deploy/
	cp patched-resigned.ipa deploy/
	cd deploy/
	unzip -q patched-resigned.ipa
	ios-deploy -b Payload/*.app/ -W -d
}

message() {
	to_print="$1"
	echo -e "${YELLOW}${to_print}${END}"
}



message "[*] Checking files"
check_files
message "[*] Adding FridaGadget to application"
add_frida
message "[*] Zipping application"
zip_application
message "[*] Signing application"
sign_app
message "[*] Deploying"
deploy
