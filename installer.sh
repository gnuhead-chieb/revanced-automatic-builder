#!/bin/bash
<<'////'
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
////

[[ $(uname -a | awk '{print $NF}') = "Android" ]] && {
    apt update -y && apt upgrade -y
    apt install -y wget openjdk-17 openssl jq

    ls ~/storage &>/dev/null || termux-setup-storage

    dist=/data/data/com.termux/files/usr/bin/revanced
} || {
    sudo=sudo
    dist=/usr/bin/revanced
}
$sudo wget https://github.com/gnuhead-chieb/revanced-automatic-builder/raw/main/revanced_mgr.sh -O $dist
$sudo chmod +x $dist

echo -e "
revanced-automatic-builder has installed.
Type \e[31;1mrevanced\e[m to start script!
"
