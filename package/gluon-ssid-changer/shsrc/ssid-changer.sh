#!/bin/sh

#################
# safety checks #
#################
safety_exit() {
	echo $1, exiting with error code 2
	exit 2
}
pgrep -f autoupdater >/dev/null && safety_exit 'autoupdater running'
UT=$(sed 's/\..*//g' /proc/uptime)
[ $UT -gt 60 ] || safety_exit 'less than one minute'
[ $(find /var/run -name hostapd-phy* | wc -l) -gt 0 ] || safety_exit 'no hostapd-phy*'

# only once every timeframe minutes the SSID will change to the Offline-SSID
# (set to 1 minute to change immediately every time the router gets offline)
MINUTES="$(uci -q get ssid-changer.settings.switch_timeframe)"
: ${MINUTES:=30}

# the first few minutes directly after reboot within which an Offline-SSID always may be activated
# (must be <= switch_timeframe)
FIRST="$(uci -q get ssid-changer.settings.first)"
: ${FIRST:=5}

# the Offline-SSID will start with this prefix use something short to leave space for the nodename
# (no '~' allowed!)
PREFIX="$(uci -q get ssid-changer.settings.prefix)"
: ${PREFIX:='FF_Offline_'}

if [ "$(uci -q get ssid-changer.settings.enabled)" = '0' ]; then 
	DISABLED='1'
else
	DISABLED='0'
fi

# generate the ssid with either 'nodename', 'mac' or to use only the prefix set to 'none'
SETTINGS_SUFFIX="$(uci -q get ssid-changer.settings.suffix)"
: ${SETTINGS_SUFFIX:='nodename'}

if [ $SETTINGS_SUFFIX = 'nodename' ]; then
	SUFFIX="$(uname -n)"
	# 32 would be possible as well
	if [ ${#SUFFIX} -gt $((30 - ${#PREFIX})) ]; then
		# calculate the length of the first part of the node identifier in the offline-ssid
		HALF=$(( (28 - ${#PREFIX} ) / 2 ))
		# jump to this charakter for the last part of the name
		SKIP=$(( ${#SUFFIX} - $HALF ))
		# use the first and last part of the nodename for nodes with long name
		SUFFIX=${SUFFIX:0:$HALF}...${SUFFIX:$SKIP:${#SUFFIX}}
	fi
elif [ $SETTINGS_SUFFIX = 'mac' ]; then
	SUFFIX="$(uci -q get network.bat0.macaddr | /bin/sed 's/://g')"
else
	# 'none'
	SUFFIX=''
fi

OFFLINE_SSID="$PREFIX$SUFFIX"

# get all SSIDs (replace \' with TICX and back to keep a possible tic in an SSID)
ONLINE_SSIDs="$(uci show | grep wireless.client_radio[0-9]\. | grep ssid  | awk -F '='  '{print $2}' | sed "s/\\\'/TICX/g" | tr \' \~ | sed "s/TICX/\\\'/g" ) "
# if for whatever reason ONLINE_SSIDs is NULL:
: ${ONLINE_SSIDs:="~FREIFUNK~"}

# temp file to count the offline incidents during switch_timeframe
TMP=/tmp/ssid-changer-count
if [ ! -f $TMP ]; then echo "0">$TMP; fi
OFF_COUNT=$(cat $TMP)

TQ_LIMIT_ENABLED="$(uci -q get ssid-changer.settings.tq_limit_enabled)"
# if true, the offline ssid will only be set if there is no gateway reacheable
# upper and lower limit to turn the offline_ssid on and off
# in-between these two values the SSID will never be changed to preven it from toggeling every Minute.
: ${TQ_LIMIT_ENABLED:='0'}

if [ $TQ_LIMIT_ENABLED = 1 ]; then
	TQ_LIMIT_MAX="$(uci -q get ssid-changer.settings.tq_limit_max)"
	#  upper limit, above that the online SSID will be used
	: ${TQ_LIMIT_MAX:='45'}
	TQ_LIMIT_MIN="$(uci -q get ssid-changer.settings.tq_limit_min)"
	#  lower limit, below that the offline SSID will be used
	: ${TQ_LIMIT_MIN:='35'}
	# grep the connection quality of the currently used gateway
	GATEWAY_TQ=$(batctl gwl | grep -e "^=>" -e "^\*" | awk -F '[('')]' '{print $2}' | tr -d " ")
	if [ ! $GATEWAY_TQ ]; then
		# there is no gateway
		GATEWAY_TQ=0
	fi

	MSG="TQ is $GATEWAY_TQ, "

	if [ $GATEWAY_TQ -ge $TQ_LIMIT_MAX ]; then
		CHECK=1
	elif [ $GATEWAY_TQ -lt $TQ_LIMIT_MIN ]; then
		CHECK=0
	else
		# this is just get a clean run if we are in-between the grace periode
		echo "TQ is $GATEWAY_TQ, do nothing"
		exit 0
	fi
else
	MSG=""
	CHECK="$(batctl gwl -H|grep -v "gateways in range"|wc -l)"
fi

UP=$(($UT / 60))
M=$(($UP % $MINUTES))

HUP_NEEDED=0
if [ "$CHECK" -gt 0 ] || [ "$DISABLED" = '1' ]; then
	echo "node is online"
	LOOP=1
	# check status for all physical devices
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do
		ONLINE_SSID="$(echo $ONLINE_SSIDs | awk -F '~' -v l=$((LOOP*2)) '{print $l}')" 
		LOOP=$((LOOP+1))
		CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
		if [ "$CURRENT_SSID" = "$ONLINE_SSID" ]; then
			echo "SSID $CURRENT_SSID is correct, nothing to do"
			break
		fi
		CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
		if [ "$CURRENT_SSID" = "$OFFLINE_SSID" ]; then
			# set online
			logger -s -t "gluon-ssid-changer" -p 5 $MSG"SSID is $CURRENT_SSID, change to $ONLINE_SSID"
			sed -i "s~^ssid=$CURRENT_SSID~ssid=$ONLINE_SSID~" $HOSTAPD
			# HUP here would be to early for dualband devices
			HUP_NEEDED=1
		else
			logger -s -t "gluon-ssid-changer" -p 5 "could not set to online state: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'. Please reboot"
		fi
	done
elif [ "$CHECK" -eq 0 ]; then
	echo "node is considered offline"
	if [ $UP -lt $FIRST ] || [ $M -eq 0 ]; then
		# set SSID offline, only if uptime is less than FIRST or exactly a multiplicative of switch_timeframe
		if [ $UP -lt $FIRST ]; then 
			T=$FIRST
		else
			T=$MINUTES
		fi
		#echo minute $M, check if $OFF_COUNT is more than half of $T 
		if [ $OFF_COUNT -ge $(($T / 2)) ]; then
			# node was offline more times than half of switch_timeframe (or than $FIRST)
			LOOP=1
			for HOSTAPD in $(ls /var/run/hostapd-phy*); do
				ONLINE_SSID="$(echo $ONLINE_SSIDs | awk -F '~' -v l=$((LOOP*2)) '{print $l}')" 
				LOOP=$((LOOP+1))
				CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
				if [ "$CURRENT_SSID" = "$OFFLINE_SSID" ]; then
					echo "SSID $CURRENT_SSID is correct, nothing to do"
					break
				fi
				CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
				if [ "$CURRENT_SSID" = "$ONLINE_SSID" ]; then
					# set offline
					logger -s -t "gluon-ssid-changer" -p 5 $MSG"$OFF_COUNT times offline, SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
					sed -i "s~^ssid=$ONLINE_SSID~ssid=$OFFLINE_SSID~" $HOSTAPD
					HUP_NEEDED=1
				else
					logger -s -t "gluon-ssid-changer" -p 5 "could not set to offline state: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'. Please reboot"
				fi
			done
		fi
		#else echo minute $M, just count $OFF_COUNT
	fi
	echo "$(($OFF_COUNT + 1))">$TMP
fi

if [ $HUP_NEEDED = 1 ]; then
	# send HUP to all hostapd to load the new SSID
	killall -HUP hostapd
	HUP_NEEDED=0
	echo "HUP!"
fi

if [ $M -eq 0 ]; then
	# set counter to 0 if the timeframe is over
	echo "0">$TMP
fi
