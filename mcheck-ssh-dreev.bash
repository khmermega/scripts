#!/bin/bash
#
# mcheck-ssh-osx1927.bash
#
# Copyright 2010 Rudolph Pienaar
# Children's Hospital Boston
#
# GPL v2
#

# "include" the set of common script functions
source common.bash

G_REPORTLOG=/tmp/${G_SELF}.reportLog.$G_PID
G_ADMINUSERS=rudolph.pienaar@childrens.harvard.edu

declare -i targetList

declare -a TARGETCHECK
declare -a TARGETACTION

G_SYNOPSIS="

 NAME

       mcheck-ssh-dreev.bash

 SYNOPSIS

       mcheck-ssh-dreev.bash

 DESCRIPTION
 
        'mcheck-ssh-dreev.bash' is used to check that certain script-defined
	conditions are true. If any of these conditions are false, it executes 
	a set of corrective actions.

	It should typically be called from a cron process, and this particular
	version of 'mcheck' is tailored to monitoring ssh tunnels between this
	host and remote hosts.

	This particular script sets up the web of ssh-tunnel connections allowing
	connections to FNNDSC hosts.
		
 PRECONDITIONS

	 o Conditions to check are defined in the script code itself. These
    	   are specified in two arrays: the first describing (per condition)
    	   the command to check; the second describing (per condition) whatever
    	   corrective action to run should the check command be false.
 	o  Conditions to check should be described in such a manner that, should
    	   the condition be false, the check command returns zero (0).
 
 POSTCONDITIONS

	o The corrective action (per condition) is executed if the check condition
    	  returns false (0).

 HISTORY
 24 May 2009
  o OSX1927 integration.

 07 September 2011
  o Re-routed all tunnels through 'dreev' to prevent accidental flooding of tunnel
    nexus hosts.
  o Added 'maxTunnel' check -- script will not open new tunnels if 'maxTunnel' is
    exceeded (this is an added check against flooding).   

"

###\\\
# Global variables
###///

# Actions
A_badRestart="attempting a corrective action"

# Error messages
EM_badRestart="the corrective action failed. Perhaps a target process failed?"

# Error codes
EC_badRestart=10

DREEV=dreev.tch.harvard.edu
OSX1927=osx1927.tch.harvard.edu
OSX1476=osx1476.tch.harvard.edu
DURBAN=durban.tch.harvard.edu
NATAL=natal.tch.harvard.edu
IPMI=ipmi.tch.harvard.edu
SHAKA=shaka.tch.harvard.edu
GLACIER=glacier.tch.harvard.edu
RCDRNO=rc-drno.tch.harvard.edu
PRETORIA=pretoria.tch.harvard.edu
GATE=gate.nmr.mgh.harvard.edu


targetList=20
#
##
### REVERSE TUNNELS -- from dreev
##
# VNC screen access on osx1927
TARGETCHECK[0]="tunnelCheck.bash -p 9900"
TARGETACTION[0]="tunnel.bash --reverse 	--from ch137123@${DREEV}:9900 	--to ${OSX1927}:5900"
# VNC screen access to osx1476
TARGETCHECK[1]="tunnelCheck.bash -p 1476"
TARGETACTION[1]="tunnel.bash --reverse	--from ch137123@${DREEV}:1476 	--to ${OSX1476}:5900"
# VNC screen access to Siemens Longwood 3.0T
TARGETCHECK[2]="tunnelCheck.bash -p 5214"
TARGETACTION[2]="tunnel.bash --reverse	--from ch137123@${DREEV}:5214	--to 10.3.1.214:5900"
# VNC screen access to Siemens Waltham 3.0T
TARGETCHECK[3]="tunnelCheck.bash -p 5241"
TARGETACTION[3]="tunnel.bash --reverse	--from ch137123@${DREEV}:5241	--to 10.64.4.241:5900"
# DICOM transmission/reception to osx1927
TARGETCHECK[4]="tunnelCheck.bash -p 10402"
TARGETACTION[4]="tunnel.bash --reverse 	--from ch137123@${DREEV}:10402 	--to ${OSX1927}:10401"
# Web access to 'durban'
TARGETCHECK[5]="tunnelCheck.bash -p 8000"
TARGETACTION[5]="tunnel.bash --reverse 	--from ch137123@${DREEV}:8000 	--to ${DURBAN}:80"
# Web access to 'natal'
TARGETCHECK[6]="tunnelCheck.bash -p 8800"
TARGETACTION[6]="tunnel.bash --reverse	--from ch137123@${DREEV}:8800	--to ${NATAL}:80"
# OsiriX listener on 'osx1927'
TARGETCHECK[7]="tunnelCheck.bash -p 11112"
TARGETACTION[7]="tunnel.bash --reverse 	--from ch137123@${DREEV}:11112	--to ${OSX1927}:11112"
# SVN source code repositories
TARGETCHECK[8]="tunnelCheck.bash -p 5555"
TARGETACTION[8]="tunnel.bash --reverse	--from ch137123@${DREEV}:5555	--to ${OSX2147}:22"
TARGETCHECK[9]="tunnelCheck.bash -p 5556"
TARGETACTION[9]="tunnel.bash --reverse	--from ch137123@${DREEV}:5556	--to ${NATAL}:22"
TARGETCHECK[10]="tunnelCheck.bash -p 4212"
TARGETACTION[10]="tunnel.bash --reverse	--from ch137123@${DREEV}:4212	--to ${IPMI}:22"
TARGETCHECK[11]="tunnelCheck.bash -p 4214"
TARGETACTION[11]="tunnel.bash --reverse	--from ch137123@${DREEV}:4214	--to ${SHAKA}:22"
TARGETCHECK[12]="tunnelCheck.bash -p 4216"
TARGETACTION[12]="tunnel.bash --reverse	--from ch137123@${DREEV}:4216 	--to ${GLACIER}:22"
TARGETCHECK[13]="tunnelCheck.bash -p 7777"
TARGETACTION[13]="tunnel.bash --reverse --from ch137123@${DREEV}:7777 	--to ${OSX1927}:22"
TARGETCHECK[14]="tunnelCheck.bash -p 4215"
TARGETACTION[14]="tunnel.bash --reverse	--from ch137123@${DREEV}:4215	--to ${PRETORIA}:22"
# Cluster repository
TARGETCHECK[15]="tunnelCheck.bash -p 3204"
TARGETACTION[15]="tunnel.bash --reverse	--from ch137123@${DREEV}:3204	--to ${RCDRNO}:22"

#
##
### (1/2) FORWARD TUNNELS -- maps a port on localhost to port on intermediary;
### these are connection points for reverse tunnels back to NMR.
##
# 
# tesla VNC
TARGETCHECK[16]="tunnelCheck.bash -p 4900"
TARGETACTION[16]="tunnel.bash --forward	--from 4900 --via ch137123@${DREEV} --to localhost:5900"
# kaos login
TARGETCHECK[17]="tunnelCheck.bash -p 7776"
TARGETACTION[17]="tunnel.bash --forward --from 7776 --via ch137123@${DREEV} --to localhost:7776"
# tesla login
TARGETCHECK[18]="tunnelCheck.bash -p 7775"
TARGETACTION[18]="tunnel.bash --forward	--from 7775 --via ch137123@${DREEV} --to localhost:7775  "
# kaos -- DICOM listener
TARGETCHECK[19]="tunnelCheck.bash -p 10301"
TARGETACTION[19]="tunnel.bash --forward --from 10301 --via ch137123@${DREEV} --to localhost:10301"

#
##
### FORWARD TUNNELS -- to site H
##
#
TARGETCHECK[20]="tunnelCheck.bash -p 9000"
TARGETACTION[20]="tunnel.bash --forward	--from 9000 --via rudolph@71.184.80.220 --to localhost:80 --sshArgs '-p 7778'"
TARGETCHECK[21]="tunnelCheck.bash -p 6812"
TARGETACTION[21]="tunnel.bash --forward	--from 6812 --via rudolph@71.184.80.220 --to localhost:22 --sshArgs '-p 7778'"

# Process command line options
while getopts h option ; do
        case "$option"
        in
                h)      echo "$G_SYNOPSIS"
		        shut_down 1 ;;
                \?)     echo "$G_SYNOPSIS"
                        shut_down 1 ;;
        esac
done

rm -f $G_REPORTLOG
b_logGenerate=0

for i in $(seq 0 $(expr $targetList - 1)) ; do
        result=$(eval ${TARGETCHECK[$i]})
	if (( result == 0 )) ; then
	        #echo "${TARGETACTION[$i]}"
		lprintn "Restarting target action..."
	        eval "${TARGETACTION[$i]} "
		ret_check $? || fatal badRestart
		TARGETRESTARTED="$TARGETRESTARTED $i"
		b_logGenerate=1
	fi
done

for i in $TARGETRESTARTED ; do
        echo ""
        echo -e "Failed:\t\t${TARGETCHECK[$i]}"         >> $G_REPORTLOG
        echo -e "Executed:\t${TARGETACTION[$i]}"        >> $G_REPORTLOG
        echo ""
done

if [ "$b_logGenerate" -eq "1" ] ; then
        message="
	
	$SELF
        
	Some of the events I am monitoring signalled a FAILED condition
	The events and the corrective action I implemented are:
	
$(cat $G_REPORTLOG)
	
        "
	messageFile=/tmp/$SELF.message.$PID
	echo "$message" > $messageFile
	mail -s "Failed conditions restarted" $G_ADMINUSERS < $messageFile
	rm -f $messageFile 2>/dev/null
fi

# This is commented out otherwise cron noise becomes unbearable
#shut_down 0