#!/bin/sh
# creates a reverse ssh tunnel to Base
# if an autossh daemon is already running,
# then restart autossh
#
# Evert Mouw <post@evert.net>
# history:
# - 27 dec 2015
# - 02 oct 2016
# - 28 jan 2017
# - 25 oct 2017
# - 11 nov 2017
#
# usage: tunnel.sh [seconds]
#  (wait ... seconds before starting,
#   handy to cheaply wait for a network
#   connection by guessing it's up after
#   some amount of time)
#
# TO USE:
# from Base, login to this machine using:
# ssh localhost -p $TUNNELPORT -l USERNAME
#
# to create the tunnel on boot,
# with a delay of 60 seconds (so network is up),
# and a daily check,
# add this to cron using:
# crontab -e
# @reboot /home/USERNAME/tunnel.sh 60
# @daily /home/USERNAME/tunnel.sh
# and give the user sudo permissions

REMOTEHOST="base.YOURDOMAIN.TLD"
REMOTEUSER="tunnel"
TUNNELPORT="2222"
EMAIL="YOURALIAS@YOURDOMAIN.TLD"
BASICINFO="\nusage:\nssh $REMOTEHOST -p $TUNNELPORT"
INFOMSG="$BASICINFO and have fun!"


# Delay $1 seconds on startup.
if ! [ "$1" = "" ]
then
	sleep $1
fi

# First test sudo rights (kenorb, 2014).
if timeout 2 sudo id > /dev/null
then
	# Secondly test if the ssh connection is alive.
	if nc -z localhost $TUNNELPORT
	then
		echo "autossh tunnel still alive, not restarting\n$INFOMSG" | mail -s "#~ autossh alive" $EMAIL
	else
		# If not alive, restart autossh.
		while pidof autossh > /dev/null
		do
			# Restart autossh.
			sudo killall autossh
			sleep 2
		done
		# Creating reverse ssh tunnel to Base.
		# Note that the additional -L local port forwarding loop enables us
		# to test from this machine whether the ssh tunnel is alive ;-)
		autossh -M 0 -f -q -N -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
		-o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" \
		-R \*:$TUNNELPORT:localhost:22 -L $TUNNELPORT:localhost:$TUNNELPORT \
		"$REMOTEUSER@$REMOTEHOST"
		echo "autossh tunnel established\n$INFOMSG" | mail -s "#~ autossh (re)started" $EMAIL
	fi
else
	echo "$0 on $(hostname) needs sudo rights!" | mail -s "#! sudo problem" $EMAIL
fi
