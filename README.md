# revanced-creator
[![CI](https://github.com/XDream8/revanced-creator/actions/workflows/Build.yml/badge.svg)](https://github.com/XDream8/revanced-creator/actions/workflows/Build.yml) \
this script first downloads the latest [revanced-cli](https://github.com/revanced/revanced-cli), [revanced-patches](https://github.com/revanced/revanced-patches) and [revanced-integrations](https://github.com/revanced/revanced-integrations). then it downloads the latest supported youtube version and patches it according to [revanced-documentation](https://github.com/revanced/revanced-documentation) \
Now we even support patching YouTube-Music \
**Check out [github actions](https://github.com/XDream8/revanced-creator/actions) (they are all built using this script. also non-root variant there includes vanced-microg.apk inside it)**
## deps
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
#### additional_args
we include `enable-wide-searchbar` patch and exclude `hide-shorts-button` here
```sh
$ export additional_args="-i enable-wide-searchbar -e hide-shorts-button"
$ ./patch.sh
```
#### what_to_patch(defaults to youtube)
```sh
$ export what_to_patch="youtube-music"
$ ./patch.sh
```
#### apk_version(YouTube: 17.26.35 and 17.27.39, YouTube-Music: 5.14.53)
```sh
$ export apk_version=17.27.39
$ ./patch.sh
```
#### nonroot(defaults to 1)
```sh
$ export nonroot=1
$ ./patch.sh
```
#### downloader
```sh
$ export downloader="axel -n 16"
$ ./patch.sh
```
#### or you can use all these options together
```sh
$ export nonroot=1
$ export downloader="axel -n 16"
$ export additional_args="-i enable-wide-searchbar -e hide-shorts-button"
$ export what_to_patch="youtube"
$ export apk_version=17.27.39
$ ./patch.sh
```
### mentions
- @halal-beef [added CI](https://github.com/XDream8/revanced-creator/pull/3) which was a great help
