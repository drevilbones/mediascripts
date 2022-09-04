#!/bin/bash

fname="dl.txt"
cont=""

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

if [[ -f $fname ]]; then
	echo -n "Continue previous download? "
	yesno
	if [[ $? = 1 ]]; then
		cont="-c"
	fi
elif [ $# -eq 0 ]; then
	echo "Need archive name pls"
	exit 1
else
	ia list --location $1 > $fname 
	cp $fname "${fname}.bak"
	vi $fname
fi

aria2c -x 10 -s 10 -k 50M --summary-interval=0 -j 1 -i $fname $cont

echo -n "Delete list?"
yesno
if [[ $? = 1 ]]; then
	rm dl.txt
	echo "List deleted."
fi

