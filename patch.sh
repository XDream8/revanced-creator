#!/bin/sh

#---------------------------#
#       Made by XDream8     #
#---------------------------#
#           deps            #
#---------------------------#
# curl, wget or $downloader #
# (optional)  awk           #
#         java(17)          #
#          grep             #
#---------------------------#

get_latest_version_info() {
	if [ ! "$(command -v curl)" ]; then
		printf '%s\n' "curl is required, exiting!"
		exit 1
	fi
	revanced_cli_version=$(curl -s -L https://github.com/revanced/revanced-cli/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | head -n 1 | cut -d"/" -f1)
	revanced_patches_version=$(curl -s -L https://github.com/revanced/revanced-patches/releases/latest | awk 'match($0, /([0-9][.]+).*.jar/) {print substr($0, RSTART, RLENGTH)}' | head -n 1 | cut -d"/" -f1)
	revanced_integrations_version=$(curl -s -L https://github.com/revanced/revanced-integrations/releases/latest | grep -o 'revanced/revanced-integrations/releases/download/v[0-9].*/.*.apk' | grep -o "[0-9].*" | cut -d"/" -f1)
}

remove_old() {
	printf '%s\n' "removing olds"
	rm -f revanced-cli-*.jar revanced-patches-*.jar app-release-unsigned.apk YouTube-$youtube_version.apk *.keystore
}

download_needed() {
	# number
	if [ "$(command -v awk)" ]; then
		n=0
	fi
  printf '%s\n' "Downloading revanced-cli, revanced-patches and revanced-integrations"
	for i in \
		https://github.com/revanced/revanced-cli/releases/download/v$revanced_cli_version/revanced-cli-$revanced_cli_version-all.jar \
		https://github.com/revanced/revanced-patches/releases/download/v$revanced_patches_version/revanced-patches-$revanced_patches_version.jar \
		https://github.com/revanced/revanced-integrations/releases/download/v$revanced_integrations_version/app-release-unsigned.apk \
		$youtube_apk
	do
		if [ "$(command -v awk)" ]; then
			n=$(awk "BEGIN {print $n+1}")
			printf '%s\n' "$n) downloading $i"
		else
			printf '%s\n' "downloading $i"
		fi
		$downloader $i
	done
}

patch() {
	if [ $nonroot = 1 ]; then
		root_text="non-root"
	else
		root_text="root"
	fi
	printf '%s\n' "patching process started($root_text)"
	printf '%s\n' "it may take a while please be patient"
	if [ $nonroot = 1 ]; then
		java -jar revanced-cli-$revanced_cli_version-all.jar \
		 -a YouTube-$youtube_version.apk \
		 -c \
		 -o revanced-$youtube_version.apk \
		 -b revanced-patches-$revanced_patches_version.jar \
		 -m app-release-unsigned.apk
	else
		java -jar revanced-cli-$revanced_cli_version-all.jar \
		 -a YouTube-$youtube_version.apk \
		 -c \
		 -o revanced-$youtube_version.apk \
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

	if [ ! -z "$downloader" ] && [ ! "$(command -v $downloader)" ]; then
		printf '%s\n' "please install a proper downloader(wget, curl)"
		exit 1
	fi

	[ -z "$nonroot" ] && nonroot=1

	get_latest_version_info
	remove_old
	download_needed
	patch
	exit 0
}

main
