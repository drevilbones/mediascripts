#!/bin/bash

OUTPUT_DIR="/mnt/big/incoming"
SOURCE_DRIVE="/dev/sr0"
HANDBRAKE_PRESET="HQ 480p30 Surround"
EXTENSION="mkv"

if [ $# -lt 3 ]; then
  echo "Please specify show title, season, and first episode index"
  echo "example: tvdvdrip.sh Red_Dwarf 2 1"
  exit 1
fi

DVD_TITLE=$1
SEASON=$2
EPINDEX=$3

# Replace spaces with underscores
DVD_TITLE=${DVD_TITLE// /_}

# Backup the DVD to hard drive
dvdbackup -i $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE

# Read handbrake's stderr into variable
rawout=$(HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE -t 0 --min-duration 0 2>&1 >/dev/null)
# Parse the variable using grep to get the number of titles
count=$(echo $rawout | grep -Eao "\\+ title [0-9]+:" | wc -l)
# Find title index of main feature
mainfeat=$(HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE -t 0 --main-feature 2>&1 >/dev/null | grep "Found main feature title" | tr -dc '0-9')

# Loop through the titles found 
for titlenum in $(seq $count)
do
	# Skip the main feature bc on tv discs it's usually all episodes in one file
	if [[ $titlenum == $mainfeat ]]; then
		continue
	fi	
	HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE \
		--title $titlenum --min-duration 300 \
		-o "$OUTPUT_DIR/$DVD_TITLE-S${SEASON}T${titlenum}.$EXTENSION" \
		--preset="$HANDBRAKE_PRESET" -N eng --subtitle-burned=none
done

# Clean up
cd $OUTPUT_DIR
# Delete raw DVD output
rm -R $DVD_TITLE/

#Done
eject $SOURCE_DRIVE
