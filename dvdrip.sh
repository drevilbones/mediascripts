#!/bin/bash

OUTPUT_DIR="/big/incoming"
SOURCE_DRIVE="/dev/sr0"
HANDBRAKE_PRESET="Good DVDs"
PRESET_FILE="DVD.json"
EXTENSION="mkv"

function rip_dvd() {

	# Grab the DVD title
	DVD_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
	# Replace spaces with underscores
	DVD_TITLE=${DVD_TITLE// /_}

	# Backup the DVD to out hard drive
	dvdbackup -i $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE

	# And now we can start encoding
	HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE -o $OUTPUT_DIR/$DVD_TITLE.$EXTENSION --preset-import-file "$PRESET_FILE" --preset="$HANDBRAKE_PRESET" --markers --min-duration 60 -N eng --subtitle-burned=none

	# Clean up
	cd $OUTPUT_DIR
	rm -R $DVD_TITLE
	
	#Done
	eject $SOURCE_DRIVE	
}

rip_dvd
