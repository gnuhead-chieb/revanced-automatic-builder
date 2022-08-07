#!/bin/bash
<<'////'
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
////

cli_api="https://api.github.com/repos/revanced/revanced-cli/releases/latest"
patches_api="https://api.github.com/repos/revanced/revanced-patches/releases/latest"
integrations_api="https://api.github.com/repos/revanced/revanced-integrations/releases/latest"

apps=("youtube" "music" "twitter" "reddit" "warnwetter")

youtube=(
    "Youtube"
    "youtube"
    "https://apkcombo.com/youtube/com.google.android.youtube"
)
music=(
    "Youtube Music"
    "music"
    "https://apkcombo.com/youtube-music/com.google.android.apps.youtube.music"
)
twitter=(
    "Twitter"
    "android"
    "https://apkcombo.com/twitter/com.twitter.android"
)
reddit=(
    "Reddit"
    "frontpage"
    "https://apkcombo.com/reddit/com.reddit.frontpage"
)
warnwetter=(
    "WarnWetter"
    "warnapp"
    "https://apkcombo.com/warnwetter/de.dwd.warnapp"
)
pwd=$(pwd)
mkdir ~/.revanced &>/dev/null; cd ~/.revanced
function getappver(){
    [[ -z $verlist ]] && verlist=$(java -jar cli-* -c -b patches-* -m integrations-* -a- -o- -l --with-versions --with-packages)
    local ver=$(eval grep -m1 \$\{$1[1]\}<<<"$verlist" | awk '{print $NF}')
    grep -P "[^0-9\.]+"<<<$ver >/dev/null && ver="all"
    echo $ver
}

##Check version and download revanced packages
for pkg in cli patches integrations
do
    ver=$(eval curl -s '$'${pkg}_api  | jq -r ".name")
    download=$(eval curl -s '$'${pkg}_api  | jq -r ".assets[-1].browser_download_url")
    ls $pkg-$ver &>/dev/null && echo ${pkg^}:updated! || { rm -f $pkg-*; wget "$download" -c -t 15 -O $pkg-$ver; }
done

#List patch available app versions
{
opt=0
for pkg in ${apps[@]}
do
    eval echo "$opt:\${$pkg[0]},$(getappver $pkg)"
    ((opt++))
done; }|column -t -s,

while true
do
    echo -n ">"
    read menuinput
    [[ $menuinput -ge 0 ]] && [[ $menuinput -lt ${#apps[@]} ]] && break
done

#Download required apk from APKCombo and patch
rm -f ${apps[$menuinput]}-orig.apk &>/dev/null
ver=$(getappver ${apps[$menuinput]})
[[ "$ver" = "all" ]] && req="apk" || req="phone-${ver}-apk"
wget $(eval curl -s "\${${apps[$menuinput]}[2]}/download/${req}" | grep -oPm1 "(?<=href=\")https://download.apkcombo.com/.*?(?=\")")\&$(curl -s "https://apkcombo.com/checkin") -O ${apps[$menuinput]}-orig.apk
java -jar cli-* -b patches-* -m integrations-* -a ${apps[$menuinput]}-orig.apk -c -o ${apps[$menuinput]}-patched.apk
mv ${apps[$menuinput]}-patched.apk $pwd

#Install apk if script running on Termux
[[ $(uname -a | awk '{print $NF}')="Android" ]] && {
    mv $pwd/${apps[$menuinput]}-patched.apk /sdcard/
    echo "Your patched apk was saved in \"/storage/emulated/0/\""
    echo "Do you want install patched apk?(y/n)"
    while true
    do
        echo -n ">"
        read isinstall
        case "$isinstall" in
            [yY]es | [yY] ) { termux-open /sdcard/${apps[$menuinput]}-patched.apk; break; } ;;
            [nN]o | [nN] ) break ;;
        esac
    done
}
