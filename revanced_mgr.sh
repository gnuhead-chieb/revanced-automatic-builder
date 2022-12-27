#!/bin/bash
<<'////'
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
////

cli_api="https://api.github.com/repos/revanced/revanced-cli/releases/latest"
patches_api="https://api.github.com/repos/revanced/revanced-patches/releases/latest"
integrations_api="https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
vc=1

apps=("youtube" "music" "twitter" "reddit" "warnwetter" "ecmwf" "tiktoka" "tiktokg" "spotify")

youtube=(
    "Youtube"
    "https://apkcombo.com/youtube/com.google.android.youtube"
)
music=(
    "Youtube Music"
    "https://apkcombo.com/youtube-music/com.google.android.apps.youtube.music"
)
twitter=(
    "Twitter"
    "https://apkcombo.com/twitter/com.twitter.android"
)
reddit=(
    "Reddit"
    "https://apkcombo.com/reddit/com.reddit.frontpage"
)
warnwetter=(
    "WarnWetter"
    "https://apkcombo.com/warnwetter/de.dwd.warnapp"
)
ecmwf=(
    "Pflotsh ECMWF"
    "https://apkcombo.com/pflotsh-ecmwf/com.garzotto.pflotsh.ecmwf_a"
)
tiktoka=(
    "TikTok(Asia)"
    "https://apkcombo.com/tiktok-asia/com.ss.android.ugc.trill"
)
tiktokg=(
    "Tiktok(Global)"
    "https://apkcombo.com/tiktok/com.zhiliaoapp.musically"
)
spotify=(
    "Spotify"
    "https://apkcombo.com/spotify/com.spotify.music"
)
pwd=$(pwd)
mkdir ~/.revanced &>/dev/null; cd ~/.revanced
[[ $(uname -a | awk '{print $NF}') = "Android" ]] && isDroid=true || isDroid=false
function getappver(){
    ver=$(jq -r ".[].compatiblePackages[]|select(.name==\"$(eval echo \${$1[1]} | awk -F/ '{print $NF}')\")|.versions[]" ./patches.json | awk '{if(m<$NF) m=$NF} END{print m}')
    [[ -n "$ver" ]] || ver="all"
    echo $ver
}

##Check version and download revanced packages
for pkg in cli patches integrations
do
    ver=$(eval curl -s '$'${pkg}_api  | jq -r ".name")
    download=$(eval curl -s '$'${pkg}_api  | jq -r ".assets[-1].browser_download_url")
    ls $pkg-$ver &>/dev/null && echo ${pkg^}:updated! || { rm -f $pkg-*; wget "$download" -c -t 15 -O $pkg-$ver; }
done
$isDroid && [[ ! -e aapt2 ]] && wget https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/aapt2/$(getprop ro.product.cpu.abi)/aapt2

#Check script version
[[ $(curl -fsSL https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/aapt2/vc) -gt $vc ]] && curl -fsSL https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/main/installer.sh | bash

#Fetch Patches database
wget https://github.com/revanced/revanced-patches/raw/main/patches.json &>/dev/null

exclude=""
if [ $# -eq 2 ]; then
    if [ "$1" == "--exclude" ] || [ "$1" == "-e" ]; then
        excludes=$2
        exclude=" -e ${excludes//,/ -e }"
    fi
fi
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
    read -p ">" menuinput
    chk=0
    for i in $menuinput
    do
        { [[ $i =~ ^[0-9]+$ ]] && [[ $i -ge 0 ]] && [[ $i -lt ${#apps[@]} ]]; } || chk=1
    done
    [[ $chk = 0 ]] && break
done

#Download required apk from APKCombo and patch
for i in $menuinput
do
    rm -f ${apps[$i]}-orig.apk &>/dev/null
    ver=$(getappver ${apps[$i]})
    [[ "$ver" = "all" ]] && req="apk" || req="phone-${ver}-apk"
    wget $(eval curl -s "\${${apps[$i]}[2]}/download/${req}" | grep -oPm1 "(?<=href=\")https://download.apkcombo.com/.*?(?=\")")\&$(curl -s "https://apkcombo.com/checkin") -O ${apps[$i]}-orig.apk
    java -jar cli-* -b patches-* -m integrations-*$exclude -a ${apps[$i]}-orig.apk -c -o ${apps[$i]}-patched.apk --experimental $($isDroid && echo "--custom-aapt2-binary ./aapt2")
    mv ${apps[$i]}-patched.apk $pwd
done

#Install apk by Termux or ADB
for i in $menuinput
do
    $isDroid && {
        mv $pwd/${apps[$i]}-patched.apk /sdcard/
        grep -P "^allow-external-apps *= *true$" ~/.termux/termux.properties >/dev/null || echo "allow-external-apps = true" >>~/.termux/termux.properties
        echo "Your patched apk was saved in \"/storage/emulated/0/\""
        echo "Do you want install patched apk?(y/n)"
        while true
        do
            read -p ">" isinstall
            case "$isinstall" in
                [yY]es | [yY] ) { termux-open /sdcard/${apps[$i]}-patched.apk; break; } ;;
                [nN]o | [nN] ) break ;;
            esac
        done
    } || {
        echo "Do you want install patched apk by ADB?(y/n)"
        while true
        do
            read -p ">" isinstall
            case "$isinstall" in
                [yY]es | [yY] ) { adb install $pwd/${apps[$i]}-patched.apk; break; } ;;
                [nN]o | [nN] ) break ;;
            esac
        done
    }
done
