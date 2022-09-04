#!/bin/bash

OUTPUT_DIR="/mnt/big/incoming"
SOURCE_DRIVE="/dev/sr0"
HANDBRAKE_PRESET="HQ 720p30 Surround"
EXTENSION="mkv"

function rip_dvd() {

	# Grab the DVD title
	DVD_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
	# Replace spaces with underscores
	DVD_TITLE=${DVD_TITLE// /_}

	# Backup the DVD to out hard drive
	dvdbackup -i $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE

	#Done
	eject $SOURCE_DRIVE	
}

rip_dvd
