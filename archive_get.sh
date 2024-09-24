#!/bin/bash

#set -x

dllist="dl.txt"
root="/big/incoming"
arname=$1
fullpath="$root/$1/"
cont=""
keepmeta=n
onlyfiles=n
keepdirs=y
editlist=n
format=""

yesno() {
	while true; do
		read -n 1 -p "(y/n): " answr
		echo -e "\n"
		case $answr in
			[yY] ) return 1;
				break;;
			[nN] ) return 0;
				break;;
			* ) echo "Y or N please";;
		esac
	done
}

print_usage() {
	echo "Usage:"
	echo "archive_get.sh [ia archive name] <options>"
	echo "where:"
        echo "[ia archive name] is the end of the URL for the IA archive you want to download"
	echo "<options> are one of the following:"
	echo "  -e: edit the download list in vim after generating it"
	echo "  -f [format]: only download files of the given format"
	echo "  -d: don't keep directory structure, just dump everything in one folder"
	echo "  -k: keep the usual internet archive metadata files (xml, sqlite, __ia_thumb.jpg, etc)"
	echo "      otherwise they get skipped when downloading"
	exit 1
}


if [ $# -gt 1 ]; then
	shift
	while [[ "$#" -ge 1 ]]; do
		case $1 in
			-k) 
				keepmeta=y
				;;
			-d)
				keepdirs=n
				;;
			-e)
				editlist=y
				;;
			-f) 
				onlyfiles=y
				format="$2"
				if [ -z "$format" ]; then
					echo "Format mode indicated but no format set"
					print_usage
				fi
				shift
			    	;;
			-h|--help)
				print_usage
				exit
				;;
			*) echo "Invalid parameter: $1"; exit 1;;
		esac
		shift
	done
fi


if [ -z $arname ]; then
	print_usage
	exit
elif [[ -f "$fullpath/$dllist" ]]; then
	echo -n "Continue previous download? "
	yesno
	if [[ $? = 1 ]]; then
		cont="-c"
	fi
else	
	mkdir -p $fullpath
	echo "Grabbing the file list and processing..."

	if [ "$onlyfiles" == "y" ]; then
		arformats=$(ia metadata --formats $arname)
		if echo "$arformats" | grep -q "$format"; then
			ia list --location -f "$format" "$arname" > $fullpath/$dllist
		else
			echo "$format is not valid"
			echo "These are the formats available for $arname:"
			echo "$arformats"
			exit
		fi
	else
		ia list --location "$arname" > "$fullpath/$dllist"
		if [ "$keepmeta" == "n" ]; then
			sed -i'.bak' '/_thumb.jpg\|_rules.conf\|_files.xml\|_meta.sqlite\|_meta.xml\|_archive.torrent\|_reviews.xml/d' $fullpath/$dllist
		fi
	fi

	if [ "$editlist" == "y" ]; then
		vi "$fullpath/$dllist"
	fi

	if [[ "$keepdirs" == "y" ]]; then
		while read line; do
			echo "$line" >> "$fullpath/temp.txt"
			dir=$(echo $line | cut -d \/ -f 6-)
			dir=${dir%/*}/
			echo "  dir=$dir" >> "$fullpath/temp.txt"
		done <"$fullpath/$dllist"

		mv "$fullpath/$dllist" "$fullpath/$dllist.bak"
		mv "$fullpath/temp.txt" "$fullpath/$dllist"
	fi
fi


cd $fullpath
aria2c -x 10 -s 10 -k 10M -j 1 --console-log-level=warn --summary-interval=0 --download-result=full -i $dllist $cont


echo -n "Delete list?"
yesno
if [[ $? = 1 ]]; then
	rm $dllist
	if [ -f "$dllist.bak" ]; then
		rm "$dllist.bak"
	fi
	echo "List deleted."
fi

