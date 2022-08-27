## Syntax Explanation in the script

#### Multiple line commentout

```
<<'////'
SOME
COMMENTS
LINES
////
```

#### &&{ ;}||{ ;} syntax

Same as if syntax,but I use this syntax because more simple.

```
[ Conditional ] && {
    (When true)
} || {
    (When false)
}
```

#### Grouping Commands

It can treat multiple commands stdout as one command stdout.

##### **Script**

```
{
    echo foo,bar,baz
    echo hoge,fuga,piyo
}|column -t -s,
```

##### **Output**

```
foo   bar   baz
hoge  fuga  piyo
```

#### Here document

It is also method of sending stdin to a command similar to a pipe.

```
cat </path/to/file_input
## Same as: cat /path/to/file_input | cat

cat <<"EOF"
foo
bar
baz
EOF
## Same as: echo -e "foo\nbar\nbaz" | cat

cat <<"Your Stdin text"
## Same as: echo "Your Stdin text" | cat
```

## Explanation of how does script work

#### 1.Check and download updates of revanced packages

Script will request to [github api](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L8-L10) and check if current version is outdated.

jq command parses responce from API.

Version information will parsed from [***".name"***](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L67),and download URL from [***".assets[-1].browser_download_url"***](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L68).

Current version is saved directry in the [filename of its binary](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L69).

##### 2.List patch available app versions

App version checking process is [functionized](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L57-L62).

Extract neccesary data from [this command](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L58) and return.

Here is flow of extraction of latest version information of specific app(Youtube in this example )

```
$ java -jar cli-* -c -b patches-* -m integrations-* -a- -o- -l --with-versions --with-packages
INFO:      trill                       tiktok-ads       Removes ads from TikTok.         
INFO:  musically                       tiktok-ads       Removes ads from TikTok.         
INFO:    youtube                   swipe-controls       Adds volume and brightness swipe controls.      17.24.34, 17.25.34, 17.26.35, 17.27.39, 17.28.34, 17.29.34, 17.32.35 
INFO:    youtube                        downloads       Enables downloading music and videos from YouTube. 17.27.39, 17.29.34, 17.32.35 

 $ !! | grep -m1 ${youtube[1]}
INFO:    youtube                   swipe-controls       Adds volume and brightness swipe controls.      17.24.34, 17.25.34, 17.26.35, 17.27.39, 17.28.34, 17.29.34, 17.32.35 

$ !! | awk '{print $NF}'
17.32.35
```

function is called first from [here](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L78).

[Variable \$opt](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L75) is [incremented](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L79) every version information inquiry to function.This number is for [user input](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L82-L91) of which apps do you wanna patch,it corresponds to the element number of the [\$apps\[\] array](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L12).

#### 3.Download original apk from apkcombo

Downloading function is [here](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L98-L99).Script generates download URL for required version and call Apkcombo's checkin API to generate token.

Script will automaticlly downloads apk from URL with checkin token.

#### 4.Installing apk

$isDroid is boolean variable that if user running on Termux defined [here](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L56).

[termux-open](https://github.com/gnuhead-chieb/revanced-automatic-builder/blob/5a680edfcc5950c833fc8e6d3bab0bb9c51f9219/revanced_mgr.sh#L116) command will open system installer dialog.

## FAQ

#### Why script download original apk from Apkcombo?

Because Apkpure and Apkmirror uses Cloudflare UAM,this may prevent scraping web site from curl request.

So,the only way to avoid this problem is webview based crawrer such as puppeteer,playwright,selenium.but if use them, it will depend nodejs and makes too bloat.

#### Where is working directory?

Working directory is under ~/.revanced. Downloaded binaries,keystore,cache is saved in this directory.

#### I wanna contribute to this project, but I have parts of process that I dont understand how it works!

Please create new issue.
