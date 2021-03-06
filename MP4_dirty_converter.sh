#!/bin/bash
v=0.4

DIR=*
START=$(date +%s)
sample_rate=44000


echo -e "\033[1mMP4 Dirty Converter\033[0m"
echo -e "Convert directory full of dirty MP4 to clean cool mp3"
echo "TGrif - direct-shoot.com / WTFPL 2017"
echo


if ! which ffmpeg > /dev/null;
then
  echo
  echo -e "\033[31mFatal error: ffmpeg should be installed on your system!\033[0m"
  exit
fi


while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo -e "Usage:";
      echo -e "-h --help          show help & exit"
      echo -e "-v --version       show version & exit"
      echo -e "-f --format        specify file format to convert (default is mp4)"
      echo -e "-d --directory     specify directory (default is current directory)"
      echo -e "-o --output        specify output directory (default is current directory)"
      echo -e "-s --sample_rate   specify convertion sample rate (default is 44k)"
      echo -e "-R --remove        delete MP4 original file after convertion"
      echo -e
      exit;;
    -v|--version)
      echo
      echo "MP4 Dirty Converter Version: $v"
      echo $(ffmpeg -version | awk 'NR==1;')
      echo
      exit;;
    -f|--format)
      echo "Sorry, --format option not implemented yet"
      exit;;
    -d|--directory)
      if [ "$2" = "" ];
      then
        echo "Error: $1 requires an argument" >&2;
        exit
      else
        DIR="$2"/*  # TODO handle space in DIR param
        echo -e "\033[0;32mparsing\033[0m $2 directory full of dirty MP4"
        shift 2
      fi;;
    -o|--output)
      if [ "$2" = "" ];
      then
        echo "Error: $1 requires an argument" >&2;
        exit
      else
        OUT="$2"
        shift 2
      fi;;
    -s|--sample_rate)
      # if [ "$2" = "" ];
      # then
      #   echo "Error: $1 requires an argument" >&2;
      #   exit
      # else
      #   sample_rate="$2"
      #   shift 2
      # fi;;
      echo "Sorry, --sample_rate option not implemented yet"
      exit;;
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


# OIFS="$IFS"
# IFS=$'\n'
for file in $DIR
do
  # TODO check if file is a directory
  echo "$file"
  FORMAT=$(ffprobe "$file" -show_format 2>/dev/null | awk -F "=" '$1 == "format_name" {print $2}')  # http://superuser.com/a/439812
  if [ "$FORMAT" = "mov,mp4,m4a,3gp,3g2,mj2" ];
  then
    MIMETYPE=$(file -b --mime-type "$file")
    echo -n -e "\033[0;32mconvert\033[0m $file [$MIMETYPE]"

    RENAME="${file%.*}"

    # TODO loglevel not used
    # TODO add taux d'échantillonage variable
    ffmpeg -loglevel panic -i "$file" -vn -acodec libmp3lame -ac 2 -ab 160k -ar $sample_rate "$RENAME.mp3" 2>/dev/null &
    pid=$!

    spin='-\|/'

    # i=0  # TODO
    # while kill -0 $pid 2>/dev/null
    # do
    #   i=$(( (i+1) %4 ))
    #   printf "\r${spin:$i:1}"
    #   sleep .1
    # done
    echo -e " \e[92m✓\033[0m"

    if [ "$REMOVE" = true ];
    then
      echo -n -e "\e[35mremove\033[0m $file"
      rm "$file"
      echo -e " \e[92m✓\033[0m"
    fi

    if [ -n "$OUT" ];
    then
      mkdir -p "$OUT"
      mv "$RENAME.mp3" "$OUT/$RENAME.mp3"
    fi

  else
    echo -e "\e[94mskip\033[0m $file"
  fi
# read line
done
# IFS="$OIFS"


TIME=$(($(date +%s) - $START))

echo
echo -n $"Total processing time:	"
printf "%02d:%02d:%02d " $((TIME / 3600)) $(((TIME / 60) % 60)) $((TIME % 60))
echo $"($TIME seconds)"


echo -e "\033[1mDone.\033[0m"
echo
