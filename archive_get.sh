#!/bin/bash

#set -x

dllist="dl.txt"
root="/big/incoming"
arname=$1
fullpath="$root/$1/"
cont=""
keepmeta=n
onlyfiles=n
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
	echo "  -k: keep the usual internet archive metadata files (xml, sqlite, __ia_thumb.jpg, etc)"
	echo "      otherwise they get skipped when downloading"
	echo "  -f [format]: only download files of the given format"
	exit 1
}


if [ $# -gt 1 ]; then
	shift
	while [[ "$#" -ge 1 ]]; do
		case $1 in
			-k) 
				keepmeta=y
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
	if [ "$onlyfiles" = "y" ]; then
		arformats=$(ia metadata --formats $arname)
		if echo "$arformats" | grep -q "$format"; then
			ia download -d -f "$format" "$arname" > $fullpath/$dllist
		else
			echo "$format is not valid"
			echo "These are the formats available for $arname:"
			echo "$arformats"
			exit
		fi
	else
		ia list --location "$arname" > "$fullpath/$dllist"
		if [ "$keepmeta" == "n" ]; then
			sed -i'.bak' '/_thumb.jpg\|_files.xml\|_meta.sqlite\|_meta.xml\|_archive.torrent\|_reviews.xml/d' $fullpath/$dllist
		fi
	fi

	vi "$fullpath/$dllist"
fi


cd $fullpath
aria2c -x 10 -s 10 -k 50M --summary-interval=0 -j 1 -i $dllist $cont


echo -n "Delete list?"
yesno
if [[ $? = 1 ]]; then
	rm $dllist
	if [ -f "$dllist.bak" ]; then
		rm "$dllist.bak"
	fi
	echo "List deleted."
fi

