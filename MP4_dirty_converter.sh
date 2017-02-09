#!/bin/bash

DIR=*

echo
echo -e "\033[1mMP4 Dirty Converter\033[0m"
echo -e "Convert directory full of dirty MP4 to clean cool mp3"
echo "TGrif - WTFPL 2017"



if which ffmpeg > /dev/null;
then
  echo
  echo $(ffmpeg -version | awk 'NR==1;')  # http://unix.stackexchange.com/a/139099
  echo
else
  echo
  echo -e "\033[0;31mFatal error: ffmpeg should be installed on your system!\033[0m"
  exit
fi



if [ "$1" == "-h" ] || [ "$1" == "--help" ];
then
  echo
  echo "Usage: ./MP4_dirty_converter.sh [-hvd][--help --version --directory]"
  exit
elif [ "$1" == "-v" ] || [ "$1" == "--version" ];
then
  echo "MP4 Dirty Converter Version: 0.1"
  exit
elif [ "$1" == "-d" ] || [ "$1" == "--directory" ];
then
  DIR="$2"/*   #TODO vérifier le chemin du repertoire
  echo "Parsing $2 directory full of dirty MP4"
fi
#TODO ajouter un parametre format et convertir un repertoire full of dirty m4a




for file in $DIR 
do 
  FORMAT=$(ffprobe "$file" -show_format 2>/dev/null | awk -F "=" '$1 == "format_name" {print $2}')  # http://superuser.com/a/439812

  if [ "$FORMAT" == "mov,mp4,m4a,3gp,3g2,mj2" ];
  then
    MIMETYPE=$(file -b --mime-type "$file")
    echo -e "\033[0;32m$file\033[0m [$MIMETYPE]"
    
    RENAME=$(echo $file | cut -d '.' -f 1) #TODO trouver mieux car s'il y'a un point dans le nom du fichier ça marche pas
    ffmpeg -loglevel panic -i "$file" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$RENAME.mp3"
    #rm "$file" #TODO ajouter une option pour supprimer les MP4 convertis
  else
    echo "skip $file $FORMAT file"
  fi
done


echo -e "\033[1mDone.\033[0m" #TODO afficher le temps de conversion
echo



