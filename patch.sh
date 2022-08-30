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
CYAN='\033[0;36m'
NC='\033[0m'

check_dep() {
	if [ ! "$(command -v $1)" ]; then
		printf '%b\n' "${RED}$2${NC}"
		exit 1
	fi
}

checkadb() {
	if [ ! "$(pidof adb)" ]; then
		if [ "$(command -v rdo)" ]; then
			sudo=rdo
		elif [ "$(command -v doas)" ]; then
			sudo=doas
		elif [ "$(command -v sudo)" ]; then
			sudo=sudo
		else
			sudo=
		fi

		printf '%b\n' "${YELLOW}starting adb server${NC}"
		$sudo adb start-server || {
			printf '%b\n' "${RED}starting adb server failed, exiting!${NC}"
			exit 1
		}
	fi

	device_id=$(adb devices | awk 'FNR == 2 {print $1}')
	if [ "$device_id" = "" ]; then
		printf '%b\n' "${RED}your phone is not connected to pc, exiting!${NC}"
		exit 1
	else
		printf '%b\n' "${YELLOW}adb device_id=$device_id"
	fi
}

checkyt() {
	if [ ! "$(adb shell cmd package list packages | grep -o 'com.google.android.youtube')" ]; then
		printf '%b\n' "${RED}root variant: install youtube v${apk_version} on your device to mount w/ integrations, exiting!${NC}"
		exit 1
	fi
}

get_latest_version_info() {
	printf '%b\n' "${BLUE}getting latest versions info${NC}"
	revanced_cli_version=$(curl -s -L https://github.com/revanced/revanced-cli/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_patches_version=$(curl -s -L https://github.com/revanced/revanced-patches/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	# integrations
	if [ "$what_to_patch" = "youtube" ]; then
		revanced_integrations_version=$(curl -s -L https://github.com/revanced/revanced-integrations/releases/latest | awk 'match($0, /([0-9][.]+).*.apk/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	fi
	# give info
	printf '%b\n' "${YELLOW}revanced_cli_version : $revanced_cli_version${NC}"
	printf '%b\n' "${YELLOW}revanced_patches_version : $revanced_patches_version${NC}"
	[ "$revanced_integrations_version" ] && printf '%b\n' "${YELLOW}revanced_integrations_version : $revanced_integrations_version${NC}"
}

remove_old() {
	if [ "$(command -v find)" ]; then
		find . -maxdepth 1 -type f \( -name "revanced-*.jar" -or -name "$integrations_filename" \) ! \( -name "*.keystore" -or -name "$cli_filename" -or -name "$patches_filename" -or -name "$apk_filename" \) -delete
	fi
}

download_needed() {
	# number
	n=0

	printf '%b\n' "${BLUE}Downloading needed files${NC}"
	for i in \
		$cli_link \
		$patches_link \
		$integrations_link \
		$apk_link; do
		n=$((n + 1))
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloader $i
	done
}

build_apk() {
	base_cmd="java -jar $cli_filename \
		-a $apk_filename \
		-c \
		-o $output_apk \
		-b $patches_filename"
	if [ "$1" ] && [ ! "$additional_args" = "" ]; then
		# with $additional_args and required arg
		$base_cmd \
			$additional_args \
			$1
	elif [ "$1" ] && [ "$additional_args" = "" ]; then
		# with required arg
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
	printf '%b\n' "${BLUE}patching process started(${RED}$root_text${BLUE})${NC}"
	printf '%b\n' "${BLUE}it may take a while please be patient${NC}"
	if [ $root = 0 ] && [ "$what_to_patch" = "youtube" ]; then
		youtube_arg="-m $integrations_filename"
		build_apk "$youtube_arg"
	elif [ $root = 0 ] && [ "$what_to_patch" = "reddit" ]; then
		reddit_arg="-r"
		build_apk "$reddit_arg"
	elif [ $root = 0 ] && [ "$what_to_patch" = "tiktok" ]; then
		tiktok_arg="-r"
		build_apk "$tiktok_arg"
	elif [ $root = 0 ]; then
		build_apk
	elif [ $root = 1 ] && [ "$what_to_patch" = "youtube" ]; then
		root_args="-d $device_id \
			    -m $integrations_filename \
          -e microg-support \
          --mount"
		build_apk "$root_args"
	else
		root_args="-d $device_id \
          -e microg-support \
          --mount"
		build_apk "$root_args"
	fi
}

main() {

	## defaults
	[ -z "$what_to_patch" ] && what_to_patch="youtube"
	[ -z "$root" ] && root=0
	[ -z "$additional_args" ] && additional_args=""

	## check $root
	if [ $root = 0 ]; then
		root_text="non-root"
	else
		root_text="root"
		printf '%b\n' "${RED}please be sure that your phone is connected to your pc, waiting 5 seconds${NC}"
		sleep 5s
		checkadb
	fi
	
	if [ ! "$what_to_patch" = "custom" ]; then
		[ -z "$apk_version" ] && apk_version=$(curl -s -L "https://github.com/XDream8/revanced-creator/releases/tag/$what_to_patch" | awk 'match($0, /[A-z]([0-9].+).*.apk/) {print substr($0, RSTART, RLENGTH)}' | grep -ioe "$what_to_patch-[0-9].*[0-9]" | grep -o "[0-9].*[0-9]" | sort | awk 'END{print}')
	fi

	## what should we patch
	if [ "$what_to_patch" = "youtube" ]; then
		apk_filename=YouTube-$apk_version.apk
		[ -z "$output_apk" ] && output_apk=revanced-$apk_version-$root_text.apk
	elif [ "$what_to_patch" = "youtube-music" ]; then
		apk_filename=YouTube-Music-$apk_version.apk
		[ -z "$output_apk" ] && output_apk=revanced-music-$apk_version-$root_text.apk
	elif [ "$what_to_patch" = "twitter" ]; then
		apk_filename=Twitter-$apk_version.apk
		[ -z "$output_apk" ] && output_apk=revanced-twitter-$apk_version-$root_text.apk
	elif [ "$what_to_patch" = "reddit" ]; then
		apk_filename=Reddit-$apk_version.apk
		[ -z "$output_apk" ] && output_apk=revanced-reddit-$apk_version-$root_text.apk
	elif [ "$what_to_patch" = "tiktok" ]; then
		apk_filename=TikTok-$apk_version.apk
		[ -z "$output_apk" ] && output_apk=revanced-tiktok-$apk_version-$root_text.apk
	elif [ "$what_to_patch" = "custom" ]; then
		if [ -z "$apk_filename" ] && [ "$(command -v find)" ]; then
			apk_filename=$(find . -maxdepth 1 -type f \( -name "*.apk" \) ! \( -name "app-release-unsigned.apk" -or -name "revanced-*.apk" \) | sort -R | awk -F'/' 'NR==1 {print $2}')
		elif [ -z "$apk_filename" ] && [ ! "$(command -v find)" ]; then
			printf '%b\n' "${RED}please specify an apk file using 'apk_filename' arg${NC}"
			exit 1
		else
			[ -z "$apk_filename" ] && {
				printf '%b\n' "${RED}please specify an apk file using 'apk_filename' arg${NC}"
				exit 1
			}
		fi
		if [ ! -f "$apk_filename" ]; then
			printf '%b\n' "${RED}apk file does not exist, please specify an existing apk file using 'apk_filename' arg${NC}"
			exit 1
		fi
		[ -z "$output_apk" ] && output_apk=revanced-$apk_filename
	fi

	## link to download $what_to_patch
	if [ ! "$what_to_patch" = "custom" ]; then
		[ ! -f "$apk_filename" ] && apk_link=https://github.com/XDream8/revanced-creator/releases/download/$what_to_patch/$apk_filename
	fi

	## downloader
	if [ -z "$downloader" ] && [ "$(command -v curl)" ]; then
		downloader="curl -qLJO"
	elif [ -z "$downloader" ] && [ "$(command -v wget)" ]; then
		downloader="wget"
	fi

	## dependecy checks
	check_dep curl "curl is required, exiting!"
	check_dep $downloader "$downloader is missing, exiting!"
	check_dep java "java 17 is required, exiting!"
	check_dep awk "awk is required, exiting!"
	check_dep grep "grep is required, exiting!"

	## java version check
	JAVA_VERSION="$(java -version 2>&1 | grep -oe "version \".*\"" | awk 'match($0, /([0-9]+)/) {print substr($0, RSTART, RLENGTH)}')"
	if [ $JAVA_VERSION -lt 17 ]; then
		printf '%b\n' "${RED}java 17 is required but you have version $JAVA_VERSION, exiting!${NC}"
		exit 1
	else
		printf '%b\n' "${YELLOW}java version $JAVA_VERSION found${NC}"
	fi

	get_latest_version_info

	if [ ! "$what_to_patch" = "custom" ]; then
		printf '%b\n' "${YELLOW}$what_to_patch version to be patched : $apk_version${NC}"
	else
		printf '%b\n' "${YELLOW}custom apk : $apk_filename${NC}"
	fi

	##
	cli_filename=revanced-cli-$revanced_cli_version-all.jar
	patches_filename=revanced-patches-$revanced_patches_version.jar
	integrations_filename=app-release-unsigned.apk

	remove_old

	[ ! -f "$cli_filename" ] && cli_link=https://github.com/revanced/revanced-cli/releases/download/v$revanced_cli_version/$cli_filename
	[ ! -f "$patches_filename" ] && patches_link=https://github.com/revanced/revanced-patches/releases/download/v$revanced_patches_version/$patches_filename
	if [ "$what_to_patch" = "youtube" ]; then
		[ ! -f "$integrations_filename" ] && integrations_link=https://github.com/revanced/revanced-integrations/releases/download/v$revanced_integrations_version/$integrations_filename
	fi

	download_needed

	if [ $root = 1 ]; then
		printf '%b\n' "${BLUE}root variant: installing stock youtube-$apk_version first${NC}"
		adb install -r $apk_filename || {
			printf '%b\n' "${RED}install failed, exiting!${NC}"
			exit 1
		}
		checkyt
	fi

	patch
	exit 0
}

main
