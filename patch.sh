#!/bin/sh -e

#---------------------------#
#     Made by XDream8       #
#---------------------------#
#           deps            #
#---------------------------#
# aria2, axel, curl or wget #
#          awk              #
#         java(17)          #
#     grep or ripgrep       #
#---------------------------#

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

out() {
	# print a message
	printf '%b\n' "$@"
}

notset() {
	case $1 in '') return 0 ;; *) return 1 ;; esac
}

equals() {
	case $1 in "$2") return 0 ;; *) return 1 ;; esac
}

check_dep() {
	if [ ! "$(command -v "$1")" ]; then
		notset "$2" || out "${RED}$2${NC}"
		return 1
	else
		return 0
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

		out "${YELLOW}starting adb server${NC}"
		$sudo adb start-server || {
			out "${RED}starting adb server failed, exiting!${NC}"
			exit 1
		}
	fi

	device_id=$(adb devices | awk 'FNR == 2 {print $1}')
	if [ "$device_id" = "" ]; then
		out "${RED}your phone is not connected to pc, exiting!${NC}"
		exit 1
	else
		out "${YELLOW}adb device_id=$device_id${NC}"
	fi
}

checkyt() {
	# shellcheck disable=2143
	if [ ! "$(adb shell cmd package list packages | $grep -o 'com.google.android.youtube')" ]; then
		out "${RED}root variant: install $what_to_patch v${apk_version} on your device to mount w/ integrations, exiting!${NC}"
		exit 1
	fi
}

get_latest_version_info() {
	out "${BLUE}getting latest versions info"
	## revanced cli
	revanced_cli_version=$(curl -s -L https://github.com/revanced/revanced-cli/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_cli_version=${revanced_cli_version#v}
	out "${YELLOW}revanced_cli_version : $revanced_cli_version${NC}"
	## revanced patches
	revanced_patches_version=$(curl -s -L https://github.com/revanced/revanced-patches/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_patches_version=${revanced_patches_version#v}
	out "${YELLOW}revanced_patches_version : $revanced_patches_version${NC}"
	## integrations
	if [ "$integrations" = "enabled" ]; then
		revanced_integrations_version=$(curl -s -L https://github.com/revanced/revanced-integrations/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
		revanced_integrations_version=${revanced_integrations_version##v}
		out "${YELLOW}revanced_integrations_version : $revanced_integrations_version${NC}"
	fi
}

remove_old() {
	if check_dep "find"; then
		find . -maxdepth 1 -type f \( -name "revanced-*.jar" -or -name "$integrations_filename" \) ! \( -name "*.keystore" -or -name "$cli_filename" -or -name "$patches_filename" -or -name "$apk_filename" \) -delete && out "${BLUE}removed old files${NC}"
	fi
}

download_needed() {
	# number
	n=0

	out "${BLUE}Downloading needed files${NC}"
	for i in \
		$cli_link \
		$patches_link \
		$integrations_link \
		$apk_link; do
		n=$((n + 1))
		out "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloader "$i"
	done
}

patch() {
	out "${BLUE}patching process started(${RED}$root_text${BLUE})${NC}"
	out "${BLUE}it may take a while please be patient${NC}"
	base_cmd="java -jar $cli_filename \
		-a $apk_filename \
		-c \
		-o $output_apk \
		-b $patches_filename"
	# shellcheck disable=2086
	if ! notset "$additional_args"; then
		# with $additional_args
		$base_cmd \
			$additional_args
	elif notset "$additional_args"; then
		# without $additional_args
		$base_cmd
	fi
}

addarg() {
	if notset "$additional_args"; then
		additional_args="$*"
	else
		additional_args="$additional_args $*"
	fi
}

main() {

	## defaults
	notset "$what_to_patch" && what_to_patch="youtube"
	notset "$root" && root="0"
	notset "$additional_args" && additional_args=""

	## grep
	if notset "$grep" && check_dep "rg"; then
		grep="rg"
	elif notset "$grep"; then
		grep="grep"
	fi

	## downloader
	if notset "$downloader" && check_dep "aria2c"; then
		downloader="aria2c -x 16 -s 1"
	elif notset "$downloader" && check_dep "axel"; then
		downloader="axel -n 16"
	elif notset "$downloader" && check_dep "curl"; then
		downloader="curl -qLJO"
	elif notset "$downloader" && check_dep "wget"; then
		downloader="wget"
	fi

	## dependecy checks
	check_dep "curl" "curl is required, exiting!"
	equals "$downloader" "curl*" || check_dep "${downloader%% -*}" "${downloader%% -*} is missing, exiting!"
	equals "root" "1" && check_dep "adb" "adb is required for root variant, exiting!"
	check_dep "java" "java 17 is required, exiting!"
	check_dep "awk" "awk is required, exiting!"
	check_dep "${grep%% -*}" "${grep%% -*} is required, exiting!"

	## java version check
	JAVA_VERSION="$(java -version 2>&1 | $grep -o "version \".*\"" | awk 'match($0, /([0-9]+)/) {print substr($0, RSTART, RLENGTH)}')"
	if [ "$JAVA_VERSION" -lt "17" ]; then
		out "${RED}java 17 is required but you have version $JAVA_VERSION, exiting!${NC}"
		exit 1
	else
		out "${YELLOW}java version $JAVA_VERSION found${NC}"
	fi

	## check $root
	if equals "$root" "0"; then
		root_text="non-root"
	else
		root_text="root"
		out "${RED}please be sure that your phone is connected to your pc, waiting 5 seconds${NC}"
		sleep 5s
		checkadb
		addarg "-d $device_id \
          -e microg-support \
          --mount"
	fi

	## get stock apk_version
	equals "$what_to_patch" "custom" || {
		notset "$apk_version" && apk_version=$(curl -sL "https://api.github.com/repos/XDream8/revanced-creator/releases" | $grep -io "$what_to_patch-[0-9].*[0-9]" | grep -o "[0-9].*[0-9]" | uniq | sort | awk 'END{print}')
    notset "$apk_version" && {
			out "${RED}getting $what_to_patch apk version failed, exiting!${NC}"
			exit 1
		}
		out "${YELLOW}$what_to_patch version to be patched : $apk_version${NC}"
	}

	## what should we patch
	case "$what_to_patch" in
	youtube)
		apk_filename=YouTube-$apk_version.apk
		integrations="enabled"
		addarg "-e debugging"
		;;
	youtube-music)
		apk_filename=YouTube-Music-$apk_version.apk
		;;
	twitch)
		apk_filename=Twitch-$apk_version.apk
		integrations="enabled"
		addarg "-e debug-mode"
		;;
	twitter)
		apk_filename=Twitter-$apk_version.apk
		;;
	reddit)
		apk_filename=Reddit-$apk_version.apk
		;;
	tiktok)
		apk_filename=TikTok-$apk_version.apk
		integrations="enabled"
		;;
	spotify)
		apk_filename=Spotify-$apk_version.apk
		;;
	custom)
		if notset "$apk_filename" && check_dep "find"; then
			apk_filename=$(find . -maxdepth 1 -type f -iname "*.apk" -not -iname "app-release-unsigned.apk" -or -not -iname "revanced-*.apk" -or -not -iname "*.keystore" | sort -r | awk -F'/' 'NR==1 {print $2}')
		elif [ -z "$apk_filename" ] && ! check_dep "find"; then
			out "${RED}please specify an apk file using 'apk_filename' arg${NC}"
			exit 1
		else
			[ -z "$apk_filename" ] && {
				out "${RED}please specify an apk file using 'apk_filename' arg${NC}"
				exit 1
			}
		fi
		if [ ! -f "$apk_filename" ]; then
			out "${RED}apk file does not exist, please specify an existing apk file using 'apk_filename' arg${NC}"
			exit 1
		fi
		[ -z "$output_apk" ] && output_apk=revanced-$apk_filename
		out "${YELLOW}custom apk : $apk_filename${NC}"
		;;
	*)
		out "that is not supported by revanced-creator${NC}"
		exit 1
		;;
	esac

	## getting versions information
	get_latest_version_info

	## set filenames
	cli_filename=revanced-cli-$revanced_cli_version-all.jar
	patches_filename=revanced-patches-$revanced_patches_version.jar
	integrations_filename=app-release-unsigned.apk

	## add integrations arg
	if [ "$integrations" = "enabled" ]; then
		addarg "-m $integrations_filename"
	fi

	## set output apk name
	notset "$output_apk" && {
		output_apk=revanced-${what_to_patch#*-}-$apk_version-$root_text.apk
	}

	## link to download $what_to_patch
	[ ! -f "$apk_filename" ] && apk_link=https://github.com/XDream8/revanced-creator/releases/download/$what_to_patch/$apk_filename

	## remove old files with find
	remove_old

	[ ! -f "$cli_filename" ] && cli_link=https://github.com/revanced/revanced-cli/releases/download/v$revanced_cli_version/$cli_filename
	[ ! -f "$patches_filename" ] && patches_link=https://github.com/revanced/revanced-patches/releases/download/v$revanced_patches_version/$patches_filename
	if [ "$integrations" = "enabled" ]; then
		[ ! -f "$integrations_filename" ] && integrations_link=https://github.com/revanced/revanced-integrations/releases/download/v$revanced_integrations_version/$integrations_filename
	fi

	download_needed

	equals "$root" "1" && {
		out "${BLUE}root variant: installing stock youtube-$apk_version first${NC}"
		adb install -r "$apk_filename" || {
			out "${RED}install failed, exiting!${NC}"
			exit 1
		}
		checkyt
	}

	patch
}

main

# vim: set sw=4 sts=4 ft=sh:
