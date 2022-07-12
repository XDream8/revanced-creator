#!/bin/sh

#---------------------------#
#       Made by XDream8     #
#---------------------------#
#           deps            #
#---------------------------#
# wget, curl or $downloader #
# (optional)  awk           #
#         java(17)          #
#---------------------------#

youtube_version=17.26.35
youtube_apk=https://us.softpedia-secure-download.com/dl/01ccf9db9bc2bd6e329d324ce9d6ecfd/62cd54e7/800000107/apk/YouTube-$youtube_version.apk

revanced_cli_version=2.5.3
revanced_patches_version=2.13.3
revanced_integrations_version=0.23.0

remove_old() {
	printf '%s\n' "removing olds"
	rm -f revanced-cli-*.jar revanced-patches-*.jar app-release-unsigned.apk YouTube-$youtube_version.apk
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

	remove_old
	download_needed
	patch
}

main
