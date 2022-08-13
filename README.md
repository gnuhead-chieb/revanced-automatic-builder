# revanced-automatic-builder
Bash script that builds Revanced(All apps!) automaticaly. Just run script!

It also works on termux.This script is not depend with other project,pure bash script.works without nodejs.
<div align="center">
<img src="https://user-images.githubusercontent.com/41156994/184480216-d750c7f2-4a0e-42fe-8dda-1a90466e65a0.png" width="25%" height="40%" align="center"/>
<img src="https://user-images.githubusercontent.com/41156994/183309460-76a3b7bd-2fea-4195-8ad9-e58c77eeb9ce.png" width="50%" height="50%" align="center"/>
</div>

## Setup(Debian/Ubuntu/Termux)
```shell
$ apt update && apt upgrade
$ apt install wget openjdk-17 openssl jq
$ termux-setup-storage #Termux only!
$ wget https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/main/revanced_mgr.sh
$ chmod +x revanced_mgr.sh
$ ./revanced_mgr.sh
```
