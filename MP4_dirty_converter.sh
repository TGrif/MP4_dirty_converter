#!/bin/bash

DIR=*

echo
echo -e "\033[1mMP4 Dirty Converter\033[0m"
echo -e "Convert directory full of dirty MP4 to clean cool mp3"
echo "TGrif - direct-shoot.com / WTFPL 2017"



if which ffmpeg > /dev/null;
then
  echo
  echo $(ffmpeg -version | awk 'NR==1;')  # http://unix.stackexchange.com/a/139099
  echo
else
  echo
  echo -e "\033[31mFatal error: ffmpeg should be installed on your system!\033[0m"
  exit
fi



while [ "$#" -gt 0 ]; do    # https://stackoverflow.com/a/31443098/5156280
  case "$1" in
    -h|--help)
      echo -e "Usage:";
      echo -e "-h --help       show help & exit"
      echo -e "-v --version    show version & exit"
      echo -e "-d --directory  specify directory (default is current directory)"
      echo -e "-R --remove     delete MP4 source file after convertion"
      echo -e
      exit;;
    -v|--version)
      echo "MP4 Dirty Converter Version: 0.2"
      exit;;
    -d|--directory)
      if [ "$2" = "" ];
      then
        echo "$1 requires an argument" >&2;
        exit
      else
        DIR="$2"/*
        echo -e "\033[0;32mparsing\033[0m $2 directory full of dirty MP4"
        shift 2
      fi;;
    -R|--remove)
      REMOVE=true
      shift 1;;
    -*)
      echo "unknown option: $1" >&2;
      exit 1;;
    *)
      echo "unknown option: $1";
      exit 1;;
  esac
done

#TODO add --format parameter and convert a directory full of dirty m4a


START=$(date +%s)


for file in $DIR
do
  FORMAT=$(ffprobe "$file" -show_format 2>/dev/null | awk -F "=" '$1 == "format_name" {print $2}')  # http://superuser.com/a/439812
  if [ "$FORMAT" = "mov,mp4,m4a,3gp,3g2,mj2" ];
  then
    MIMETYPE=$(file -b --mime-type "$file")
    echo -n -e "\033[0;32mconvert\033[0m $file [$MIMETYPE]"

    RENAME="${file%.*}"  # https://stackoverflow.com/a/965072/5156280

    ffmpeg -loglevel panic -i "$file" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$RENAME.mp3"
    echo -e " \e[92m✓\033[0m"

    if [ "$REMOVE" = true ];
    then
      echo -n -e "\e[35mremove\033[0m $file"
      rm "$file"
      echo -e " \e[92m✓\033[0m"
    fi
  else
    echo -e "\e[94mskip\033[0m $file $FORMAT file"
  fi
done



TIME=$(($(date +%s) - $START))  # https://github.com/JakeWharton/mkvdts2ac3

echo
echo -n $"Total processing time:	"
printf "%02d:%02d:%02d " $((TIME / 3600)) $(((TIME / 60) % 60)) $((TIME % 60))
echo $"($TIME seconds)"


echo -e "\033[1mDone.\033[0m"
echo



