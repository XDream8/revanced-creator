# revanced-creator

<p align="center">
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/XDream8/revanced-creator/Tests.yml?branch=main&color=red&style=flat-square">
  <img alt="GitHub" src="https://img.shields.io/github/license/XDream8/revanced-creator?color=blue&style=flat-square">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/XDream8/revanced-creator?color=red&style=flat-square">
  <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/XDream8/revanced-creator?color=red&style=flat-square">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/XDream8/revanced-creator?style=flat-square">
  <img alt="GitHub forks" src="https://img.shields.io/github/forks/XDream8/revanced-creator?style=flat-square">
</p>

**What does this do?**

1. downloading the latest [revanced-cli](https://github.com/revanced/revanced-cli), [revanced-patches](https://github.com/revanced/revanced-patches) and [revanced-integrations](https://github.com/revanced/revanced-integrations).
2. downloading the latest supported youtube(yt-music, reddit, twitter, tiktok) version
3. creating revanced app according to [revanced-documentation](https://github.com/revanced/revanced-documentation)

**Check out [github action artifacts](https://github.com/XDream8/revanced-creator/actions) for revanced apks built with this script**.\
Download the latest CI builds [here](https://nightly.link/XDream8/revanced-creator/workflows/ci/main).
You can also download them [in codeberg releases page](https://codeberg.org/XDream8/revanced-creator/releases/tag/apks).

## deps

- sh(dash or bash)
- curl is used for fetching release numbers, aria2, axel, curl or wget is used for downloading needed files
- awk
- java(17)
- ripgrep or grep
- find(**optional**)

## usage

```sh
$ mkdir -p revanced
$ cd revanced
$ sh -c "$(curl https://raw.githubusercontent.com/XDream8/revanced-creator/main/patch.sh)"
```

- or

```sh
$ git clone https://github.com/XDream8/revanced-creator
$ cd revanced-creator
$ ./patch.sh
```

## options
there are two ways to pass config options:
- flags
- environment variables

### using cli flags
to see all available flags:
```sh
$ ./patch.sh -h
```
usage:
```sh
$ ./patch.sh --patch=youtube --additional-args="-e <patch>" --downloader="curl"
```

### using custom apk
here is how to patch user downloaded reddit apk\
(!) if apk_filename is not set, script uses find to select an apk from the directory you are in randomly(if there is only one apk in the directory you are in it is fine)\
(?) output_apk is optional

```sh
$ export what_to_patch="custom"
$ export apk_filename=reddit.apk
$ export output_apk=revanced-reddit.apk
$ ./patch.sh
```

### additional_args

we include `enable-wide-searchbar` and `swipe-controls` patch and exclude `hide-shorts-button` here

```sh
$ export additional_args="-i enable-wide-searchbar -i swipe-controls -e hide-shorts-button"
$ ./patch.sh
```

### what_to_patch(youtube, youtube-music, reddit or twitter)

```sh
$ export what_to_patch="youtube-music"
$ ./patch.sh
```

### output_apk

you can set output apk name with this

```sh
$ export output_apk="ReReddit.apk"
$ ./patch.sh
```

### apk_version(defaults to latest)

**To see versions available see the releases section**

```sh
$ export apk_version=17.27.39
$ ./patch.sh
```

#### root(defaults to 0)

```sh
$ export root=0
$ ./patch.sh
```

### downloader

aria2, axel, curl, wget; they are detected in this order and the first detected is used

```sh
$ export downloader="axel -n 16"
$ ./patch.sh
```

### or you can use all these options together

```sh
$ export root=0
$ export additional_args="-i enable-wide-searchbar -i swipe-controls -e hide-shorts-button"
$ export what_to_patch="youtube"
$ export apk_version=17.27.39
$ ./patch.sh
```

## mentions

- @halal-beef [added CI](https://github.com/XDream8/revanced-creator/pull/3) which was a great help
