#!/bin/bash

OUTPUT_DIR="/big/incoming"
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

	#Done
	eject $SOURCE_DRIVE
}

rip_bluray
