#!/bin/bash

OUTPUT_DIR="/mnt/big/incoming"
SOURCE_DRIVE="/dev/sr0"
HANDBRAKE_PRESET="HQ 1080p30 Surround"
EXTENSION="mkv"

function rip_bluray() {

	# Grab the DVD title
	BLURAY_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
	# Replace spaces with underscores
	BLURAY_TITLE=${BLURAY_TITLE// /_}

	# Backup the DVD to out hard drive
	makemkvcon backup disc:0 $OUTPUT_DIR/$BLURAY_TITLE --decrypt

	# And now we can start encoding
	HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE -o $OUTPUT_DIR/$DVD_TITLE.$EXTENSION --preset="$HANDBRAKE_PRESET" --main-feature --markers -N eng --subtitle-burned=none

	# Clean up
	cd $OUTPUT_DIR
	rm -R $BLURAY_TITLE
	
	#Done
	eject $SOURCE_DRIVE
}

rip_bluray
