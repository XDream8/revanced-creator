# revanced-creator
this script first downloads the latest [revanced-cli](https://github.com/revanced/revanced-cli), [revanced-patches](https://github.com/revanced/revanced-patches) and [revanced-integrations](https://github.com/revanced/revanced-integrations). then it downloads the latest supported youtube version and patches it according to [revanced-documentation](https://github.com/revanced/revanced-documentation)
## deps
- curl, wget or set another with $downloader
- (optional)awk
- java(17)
## usage
```sh
$ git clone https://github.com/XDream8/revanced-patcher
$ cd revanced-patcher
$ chmod +x patch.sh
$ ./patch.sh
```
### downloader option
```sh
$ downloader="axel -n 16" ./patch.sh
```
