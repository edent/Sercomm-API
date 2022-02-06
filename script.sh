#!/bin/bash

# Variables
USER=administrator
PASSWORD=cgiconfig
HOST=192.168.0.99
INPUT=./config.ini
OUTPUT=./config.ini
SECTION=ALL
# Configuration
ReadOnly="Manufacture STREAMS cfg_ver pb_status reg_interval log_level http_mode upnpcp_port_increment "
LOGFILE="./${0%.*}.log"

###############################################################################
# Parse optional arguments
###############################################################################
parse_options () {
	shift
	while true; do
		case $1 in
			-h|--host) HOST=$2 && shift
			;;
			-u|--user) USER=$2 && shift
			;;
			-p|--password) PASSWORD=$2 && shift
			;;
			-o|--output) OUTPUT=$2 && shift
			;;
			-i|--input) INPUT=$2 && shift
			;;
			-s|--section) SECTION=$2 && shift
			;;
			--help) display_usage
			;;
			*) break
		esac
		shift
	done
}

###############################################################################
# Show help menu
###############################################################################
display_usage() { 
	echo "This script read and set IP camera SERCOMM's config"
	echo
	echo "usage: $0 {get|set}"
	echo
	echo "GET : read and save camera's config in $OUTPUT file"
	echo "      CAUTION : GET usage erase $OUTPUT file if exist" 
	echo "SET : read $INPUT file and set camera's config"
	echo
	echo "Options :"
	echo "-u or --user : set user of IP camera"
	echo "               Default is $USER"
	echo "-p or --password : set user's password of IP camera"
	echo "                   Default is $PASSWORD"
	echo "-h or --host : set IP or DNS name of IP camera"
	echo "               Default is $HOST"
	echo "-i or --input : set configuration file to set IP camera's config"
	echo "                Default is $INPUT"
	echo "-o or --output : set file to save IP camera's config"
	echo "                 Default is $OUTPUT"
	echo "-s or --section : set only one section of config (eg : MOTION)"
	echo "                 Default is ALL"
	echo "--help : display this help menu"
	echo
	echo 
}

###############################################################################
# Get all IPCAM config
###############################################################################
get_config () {
	GET_GROUP="http://$HOST/adm/get_group.cgi"
	CHECK_GROUP="?group="

	echo "" >> $LOGFILE
	echo "" >> $LOGFILE
	echo "#####################################################" >> $LOGFILE
	echo "# Get IPCAM config" >> $LOGFILE
	echo "# $(date)" >> $LOGFILE
	echo "# Variables :" >> $LOGFILE
	echo "# 		Admin user : $USER" >> $LOGFILE
	echo "# 		IP address : $HOST" >> $LOGFILE
	echo "# 		Config file : $OUTPUT" >> $LOGFILE
	echo "#		Log file : $LOGFILE" >> $LOGFILE
	echo "#####################################################" >> $LOGFILE

	echo "Get list of group" >> $LOGFILE
	LIST_GROUP=$(tr -d "]\r[" <<< $(curl -u $USER:$PASSWORD $GET_GROUP))
	[ -e "$OUTPUT" ] && rm $OUTPUT && echo "Erase file $OUTPUT" >> $LOGFILE
	for GROUP in $LIST_GROUP
	do
					echo "URL config check : $GET_GROUP$CHECK_GROUP$GROUP" >> $LOGFILE
	        curl -u $USER:$PASSWORD "$GET_GROUP$CHECK_GROUP$GROUP" >> $OUTPUT
	done
	echo "End" >> $LOGFILE
}

###############################################################################
# Set IPCAM config
###############################################################################
set_config () {
	SET_GROUP="http://$HOST/adm/set_group.cgi"
	CHECK_GROUP="?group="
	echo "" >> $LOGFILE
	echo "" >> $LOGFILE
	echo "#####################################################" >> $LOGFILE
	echo "# Set up IPCAM" >> $LOGFILE
	echo "# $(date)" >> $LOGFILE
	echo "# Variables :" >> $LOGFILE
	echo "# 		Admin user : $USER" >> $LOGFILE
	echo "# 		IP address : $HOST" >> $LOGFILE
	echo "# 		Config file : $INPUT" >> $LOGFILE
	echo "# 		Section setup : $SECTION" >> $LOGFILE
	echo "#		Log file : $LOGFILE" >> $LOGFILE
	echo "#####################################################" >> $LOGFILE

	while read line
	do
		line="${line//$'\r'/}"																		# Remove '\r'
		if [ "${line::1}" = '[' ]; then														# New section start
			line="${line//[/}"																					# Remove '['
			line="${line//]/}"																					# Remove ']'
			URL="$SET_GROUP$CHECK_GROUP$line"														# Create URI
		else																											# Config in section
			line="${line//" "/"%20"}"																	# Change space by %20 (HTML code)
			check_data "$URL&$line"																		# check data
			if [[ $? == 0 ]]; then																		# Data is OK
				if [[ "$SECTION" == "ALL" ]]; then													# Set up all sections
					echo "URL config : $URL&$line" >> $LOGFILE									# Log URI command
					curl -u $USER:$PASSWORD "$URL&$line" >> $LOGFILE						# Setup config at IPCAM
				elif [[ "$URL&$line" == *"$SECTION"* ]]; then								# Set up section define
					echo "URL config : $URL&$line" >> $LOGFILE									# Log URI command
					curl -u $USER:$PASSWORD "$URL&$line" >> $LOGFILE						# Setup config at IPCAM
				fi
			fi
		fi
	done < $INPUT
	echo "End" >> $LOGFILE
}


###############################################################################
# Check IPCAM config before setup
###############################################################################
check_data () {
	# Test if config is writable
	for test in $ReadOnly
	do
		if [[ "$1" == *"$test"* ]]; then
			echo "${1/#*\?/} : data not writable" >> $LOGFILE
			return 1
		fi
	done

	# Test if data is not null
	if [ "${1/#*=/}" == '' ]; then
		echo "${1/#*\?/} : no data" >> $LOGFILE
		return 1
	fi

	# Test is user password is set
	if [[ "$1" == *"&user"* ]]; then
		if [ "${1/#*,/}" == '' ]; then
			echo "${1/#*=/} user's password is empty" >> $LOGFILE
			return 1
		fi
	fi
	return 0
}


case $1 in 	
	'get' )
		parse_options $*
		get_config
	;;
	'set' )
		parse_options $*
		set_config
	;;
	'--help' )
		display_usage
	;;
	*)
	echo "usage: $0 {get|set|--help}"
	;;
esac
