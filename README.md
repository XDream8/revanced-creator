# revanced-creator

<p align="center">
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/XDream8/revanced-creator/Tests?color=red&style=flat-square">
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

**Check out [github action artifacts](https://github.com/XDream8/revanced-creator/actions) for revanced apks built with this script**. \
Download the latest CI builds [here](https://nightly.link/XDream8/revanced-creator/workflows/Build/main).

## deps
- sh(dash or bash)
- curl(curl is required to get latest versions of revanced-*)
- awk
- java(17)
- grep
- (optional)find(we use it to remove old versions of revanced-*, if there is any)
## usage
```sh
$ mkdir -p revanced
$ cd revanced
$ sh -c "$(curl https://raw.githubusercontent.com/XDream8/revanced-creator/main/patch.sh)"
```
* or
```sh
$ git clone https://github.com/XDream8/revanced-creator
$ cd revanced-creator
$ ./patch.sh
```
### options
#### using custom apk
here is how to patch user downloaded reddit apk \
(!) if apk_filename is not set, script uses find to select an apk from the directory you are in randomly(if there is only one apk in the directory you are in it is fine) \
(!) additional arg is only for reddit, other apps does not need it \
(?) output_apk_name is optional
```sh
$ export what_to_patch="custom"
$ export apk_filename=reddit.apk
$ export output_apk=revanced-reddit.apk
$ export additional_args="-r"
$ ./patch.sh
```
#### additional_args
we include `enable-wide-searchbar` and `swipe-controls` patch and exclude `hide-shorts-button` here
```sh
$ export additional_args="-i enable-wide-searchbar -i swipe-controls -e hide-shorts-button"
$ ./patch.sh
```
#### what_to_patch(youtube, youtube-music, reddit or twitter)
```sh
$ export what_to_patch="youtube-music"
$ ./patch.sh
```
#### output_apk
you can set output apk name with this
```
$ export output_apk="ReReddit.apk"
$ ./patch.sh
```
#### apk_version(defaults to latest)
**Versions Available** \
YouTube: 17.26.35, 17.27.39, 17.28.34, 17.29.34, 17.32.35 \
YouTube-Music: 5.14.53, 5.16.51, 5.17.51 \
Twitter: 9.52.0, 9.53.0 \
Reddit: 2022.28.0 \
TikTok: 25.8.2
```sh
$ export apk_version=17.27.39
$ ./patch.sh
```
#### root(defaults to 0)
```sh
$ export root=0
$ ./patch.sh
```
#### downloader
```sh
$ export downloader="axel -n 16"
$ ./patch.sh
```
#### or you can use all these options together
```sh
$ export root=0
$ export downloader="axel -n 16"
$ export additional_args="-i enable-wide-searchbar -i swipe-controls -e hide-shorts-button"
$ export what_to_patch="youtube"
$ export apk_version=17.27.39
$ ./patch.sh
```
### mentions
- @halal-beef [added CI](https://github.com/XDream8/revanced-creator/pull/3) which was a great help
