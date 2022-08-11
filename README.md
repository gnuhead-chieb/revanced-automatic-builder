# revanced-automatic-builder
Bash script that builds Revanced(All apps!) automaticaly. Just run script!

It also works on termux.This script is not depend with other project,pure bash script.works without nodejs.

![Screenshot_20220808_051411](https://user-images.githubusercontent.com/41156994/183309460-76a3b7bd-2fea-4195-8ad9-e58c77eeb9ce.png)

## Setup(Debian/Ubuntu/Termux)
```shell
$ apt update && apt upgrade
$ apt install wget openjdk-17 openssl jq
$ termux-setup-storage #Termux only!
$ wget https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/main/revanced_mgr.sh
$ chmod +x revanced_mgr.sh
$ ./revanced_mgr.sh
```
