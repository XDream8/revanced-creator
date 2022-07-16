#!/bin/sh

#---------------------------#
#     Made by XDream8       #
#---------------------------#
#           deps            #
#---------------------------#
# curl, wget or $downloader #
#          awk              #
#         java(17)          #
#          grep             #
#---------------------------#

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
NC='\033[0m'

check_dep() {
	if [ ! "$(command -v $1)" ]; then
		printf '%b\n' "${RED}$2${NC}"
		exit 1
	fi
}

get_latest_version_info() {
	printf '%b\n' "${BLUE}getting latest versions info${NC}"
	revanced_cli_version=$(curl -s -L https://github.com/revanced/revanced-cli/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | head -n 1 | cut -d"/" -f1)
	revanced_patches_version=$(curl -s -L https://github.com/revanced/revanced-patches/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | head -n 1 | cut -d"/" -f1)
	revanced_integrations_version=$(curl -s -L https://github.com/revanced/revanced-integrations/releases/latest | grep -o 'revanced/revanced-integrations/releases/download/v[0-9].*/.*.apk' | grep -o "[0-9].*" | cut -d"/" -f1)
	for i in \
		"revanced_cli_version=$revanced_cli_version" \
		"revanced_patches_version=$revanced_patches_version" \
		"revanced_integrations_version=$revanced_integrations_version"
	do
		printf '%b\n' "${YELLOW}$i${NC}"
	done
}

remove_old() {
	printf '%b\n' "${BLUE}removing olds${NC}"
	rm -f revanced-cli-*.jar revanced-patches-*.jar app-release-unsigned.apk YouTube-$youtube_version.apk
}

download_needed() {
	# number
	n=0

	printf '%b\n' "${BLUE}Downloading revanced-cli, revanced-patches and revanced-integrations${NC}"
	for i in \
		https://github.com/revanced/revanced-cli/releases/download/v$revanced_cli_version/revanced-cli-$revanced_cli_version-all.jar \
		https://github.com/revanced/revanced-patches/releases/download/v$revanced_patches_version/revanced-patches-$revanced_patches_version.jar \
		https://github.com/revanced/revanced-integrations/releases/download/v$revanced_integrations_version/app-release-unsigned.apk \
		$youtube_apk
	do
		n=$(awk "BEGIN {print $n+1}")
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloader $i
	done
}

patch() {
	if [ $nonroot = 1 ]; then
		root_text="non-root"
	else
		root_text="root"
	fi
	printf '%b\n' "${BLUE}patching process started(${RED}$root_text${BLUE})${NC}"
	printf '%b\n' "${BLUE}it may take a while please be patient${NC}"
	if [ $nonroot = 1 ]; then
		java -jar revanced-cli-$revanced_cli_version-all.jar \
		 -a YouTube-$youtube_version.apk \
		 -c \
		 -o revanced-$youtube_version-$root_text.apk \
		 -b revanced-patches-$revanced_patches_version.jar \
		 -m app-release-unsigned.apk
	else
		java -jar revanced-cli-$revanced_cli_version-all.jar \
		 -a YouTube-$youtube_version.apk \
		 -c \
		 -o revanced-$youtube_version-$root_text.apk \
		 -b revanced-patches-$revanced_patches_version.jar \
		 -m app-release-unsigned.apk \
		 -e microg-support \
		 --mount
	fi
}

main() {

	youtube_version=17.26.35
	youtube_apk=https://github.com/XDream8/revanced-creator/releases/download/v0.1/YouTube-$youtube_version.apk

	if [ -z "$downloader" ] && [ "$(command -v curl)" ]; then
		downloader="curl -OL"
	elif [ -z "$downloader" ] && [ "$(command -v wget)" ]; then
		downloader="wget"
	fi

	check_dep curl "curl is required, exiting!"
	check_dep $downloader "$downloader is missing, exiting!"
	check_dep java "java 17 is required, exiting!"
	check_dep awk "awk is required, exiting!"
	check_dep grep "grep is required, exiting!"

	JAVA_VERSION="$(java -version 2>&1 | grep -oe "version \".*\"" | awk 'match($0, /([0-9]+)/) {print substr($0, RSTART, RLENGTH)}')"
	if [ $JAVA_VERSION -lt 17 ]; then
		printf '%b\n' "${RED}java 17 is required but you have version $JAVA_VERSION, exiting!${NC}"
		exit 1
	else
		printf '%b\n' "${YELLOW}java version $JAVA_VERSION found${NC}"
	fi

	[ -z "$nonroot" ] && nonroot=1

	get_latest_version_info
	remove_old
	download_needed
	patch
	exit 0
}

main
