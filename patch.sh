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
	if [ ! "$(command -v find)" ]; then
		[ ! -f "$cli_filename" ] && [ -f "revanced-cli-*-all.jar" ] && ( printf '%b\n' "${RED}removing old revanced-cli${NC}" && rm -f revanced-cli-*.jar )
		[ ! -f "$patches_filename" ] && [ -f "revanced-patches-*-all.jar" ] && (printf '%b\n' "${RED}removing old revanced-patches${NC}" && rm -f revanced-patches-*.jar )
		[ ! -f "$youtube_filename" ] && [ -f "YouTube-*.apk" ] && (printf '%b\n' "${RED}removing old youtube${NC}" && rm YouTube-$youtube_version )
		rm -f $integrations_filename
	else
		find . -maxdepth 1 -type f \( -name "revanced-*.jar" -or -name "$integrations_filename" \) ! \( -name "*.keystore" -or -name "$cli_filename" -or -name "$patches_filename" -or -name "$youtube_filename" \) -delete
	fi
}

download_needed() {
	# number
	n=0

	printf '%b\n' "${BLUE}Downloading revanced-cli, revanced-patches and revanced-integrations${NC}"
	for i in \
		https://github.com/revanced/revanced-cli/releases/download/v$revanced_cli_version/$cli_filename \
		https://github.com/revanced/revanced-patches/releases/download/v$revanced_patches_version/$patches_filename \
		https://github.com/revanced/revanced-integrations/releases/download/v$revanced_integrations_version/$integrations_filename \
		$youtube_apk
	do
		n=$(awk "BEGIN {print $n+1}")
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloader $i
	done
}

checkadb() {
	if [ ! "$(pidof adb)" ]; then
		if [ "$(command -v rdo)" ]; then
			sudo=rdo
		elif [ "$(command -v doas)" ]; then
			sudo=doas
		else
			sudo=sudo
		fi

		printf '%b\n' "${YELLOW}starting adb server${NC}"
		$sudo adb start-server
	fi

	device_id=$(adb devices | awk 'FNR == 2 {print $1}')
	if [ "$device_id" = "" ]; then
		printf '%b\n' "${RED}your phone is not connected to pc, exiting!${NC}"
		exit 1
	else
		printf '%b\n' "${YELLOW}adb device_id=$device_id"
	fi
}

build_apk() {
	base_cmd="java -jar $cli_filename \
		-a $youtube_filename \
		-c \
		-o revanced-$youtube_version-$root_text.apk \
		-b $patches_filename \
		-m $integrations_filename"
	if [ "$1" ] && [ ! "$additional_args" = "" ]; then
		# root with $additional_args
		$base_cmd \
		$additional_args \
		$1
	elif [ "$1" ]; then
		# root
		$base_cmd \
		$1
	elif [ ! "$1" ] && [ ! "$additional_args" = "" ]; then
		# non-root with $additional_args
		$base_cmd \
		$additional_args
	elif [ ! "$1" ] && [ "$additional_args" = "" ]; then
		# non-root
		$base_cmd
	fi
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
		build_apk
	else
		 root_args=" \
		 -d $device_id \
		 -e microg-support \
		 --mount"
		 build_apk "$root_args"
	fi
}

main() {

	youtube_version=17.26.35
	youtube_filename=YouTube-$youtube_version.apk
	youtube_apk=https://github.com/XDream8/revanced-creator/releases/download/v0.1/$youtube_filename

	if [ -z "$downloader" ] && [ "$(command -v curl)" ]; then
		downloader="curl -qLJO"
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
	[ -z "$additional_args" ] && additional_args=""

	if [ $nonroot = 0 ]; then
		printf '%b\n' "${RED}please be sure that your phone is connected to your pc, waiting 5 seconds"
		sleep 5s
		checkadb
	fi

	get_latest_version_info

	cli_filename=revanced-cli-$revanced_cli_version-all.jar
	patches_filename=revanced-patches-$revanced_patches_version.jar
	integrations_filename=app-release-unsigned.apk

	# remove_old
	# download_needed
	patch
	exit 0
}

main
