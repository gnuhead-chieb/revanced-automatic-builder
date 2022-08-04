#!/bin/bash
<<'////'
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.
////

cli_api="https://api.github.com/repos/revanced/revanced-cli/releases/latest"
patches_api="https://api.github.com/repos/revanced/revanced-patches/releases/latest"
integrations_api="https://api.github.com/repos/revanced/revanced-integrations/releases/latest"

##Check version and download revanced packages
for pkg in cli patches integrations
do
    ver=$(eval curl -s '$'${pkg}_api  | jq -r ".name")
    download=$(eval curl -s '$'${pkg}_api  | jq -r ".assets[-1].browser_download_url")
    ls $pkg-$ver &>/dev/null && echo updated! || { rm -f $pkg-*; wget "$download" -c -t 15 -O $pkg-$ver; }
done

#Download needed required apk from APKCombo
for pkg in youtube music
do
    rm -f $pkg-orig.apk &>/dev/null
    ver=$(java -jar cli-* -c -b patches-* -m integrations-* -a- -o- -l --with-versions --with-packages | grep -m1 $pkg | awk '{print $NF}')
    echo $ver
    [[ $pkg == youtube ]] && name="com.google.android.youtube" || name="com.google.android.apps.youtube.music"
    wget $(curl -s "https://apkcombo.com/youtube$([[ $pkg == music ]]&&echo -music)/${name}/download/phone-${ver}-apk" | grep -oPm1 "(?<=href=\")https://download.apkcombo.com/${name}/.*?(?=\")")\&$(curl -s "https://apkcombo.com/checkin") -O $pkg-orig.apk
done

#Patch apks
for pkg in youtube music
do
    java -jar cli-* -b patches-* -m integrations-* -a $pkg-orig.apk -c -o $pkg-patched.apk
done
