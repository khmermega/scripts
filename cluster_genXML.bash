#!/bin/bash
#
# cluster_genXML.bash
#
# Copyright 2009 Dan Ginsburg
# Children's Hospital Boston
#
# GPL v2
#
source common.bash

declare -i Gi_verbose=0
declare -i Gb_singleLine=0
declare -i Gi_lineNumber=0

G_CLUSTERFILE="-x"

G_SYNOPSIS="

 NAME

        cluster_genXML.bash

 SYNOPSIS

        cluster_genXML.bash           -f <clusterScheduleLog> \\
                                      -l <lineNumber>

 DESCRIPTION

        'cluster_genXML.bash' takes as input a <clusterScheduleLog> file
        and traverses all of the jobs in the file to produce an XML detailed
        summary of each of the jobs.  This XML file is used by the web
        front-end to display a rich browser for the cluster jobs.

 CLUSTER LOG
 
        The <clusterScheduleLog> contains a log of all the scheduled jobs
        for the cluster.  This file is generated by tract_meta.bash and
        fs_meta.bash when they are passed the -C option.
        
 ARGUMENTS

        -f <clusterScheduleLog>
        The cluster schedule.log file to process
        
        -l <lineNumber> (Optional)
        Only output XML for the specified line in the cluster schedule log.

 PRECONDITIONS
	
        o A FreeSurfer 'std' or 'dev' environment.

        o 'tract_meta.bash', 'fs_meta.bash' and related.

 POSTCONDITIONS

       
 HISTORY

       19 February 2010
       o Initial design and coding.
"

###\\\
# Globals are in capital letters. Immutable globals are prefixed by 'G'.
###///


# Actions
A_noclusterFileArg="checking on -f <clusterScheduleLog> argument"
A_stageRun="running a stage in the processing pipeline"

# Error messages
EM_noclusterFileArg="it seems as though you didn't specify a -f <clusterScheduleLog>."
EM_stageRun="I encountered an error processing this stage."

# Error codes

EC_noClusterFile=41
EC_stageRun=30

# Defaults
D_whatever=

###\\\
# Function definitions
###///
function echo_stripped
{
    # ARGS
    # $1                        string to print
    #
    # DESC
    # Strip out any non-UTF8 characters before echoing
    #

    echo -e "$@" | iconv -f UTF-8 -t UTF-8 -c | sed -e 's/\&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/\"/\&quot;/g' -e 's/\x27/\&#39;/g' 
}

###\\\
# Process command options
###///

while getopts f:l: option ; do
	case "$option"
	in
		f)	G_CLUSTERFILE=$OPTARG		;;
		l)	Gb_singleLine=1
			Gi_lineNumber=$OPTARG		;;
		\?) synopsis_show
		    exit 0;;
	esac
done

if (( !Gb_singleLine )) ; then
	echo "<?xml version=\"1.0\"?>"
fi
# Iterate over each line in the cluster file
exec<$G_CLUSTERFILE
declare -i curLine=0
while read line
do
	curLine=curLine+1
	if (( Gb_singleLine )) ; then
		if (( curLine != Gi_lineNumber )) ; then
			continue
		fi
	fi
	# Determine the cluster script name
	CLUSTERCMD=$(echo $line | awk -F \| 'NF > 1  {print $3}'| sed 's/ Stage //' | sed 's/^[ \t]*//;s/[ \t]*$//')
	if [ -f $CLUSTERCMD ] ; then
		DATE=$(echo $line | awk '{print $1,$2,$3,$4,$5,$6}' | xargs -i$ date --date='$' +"%D %R:%S %a")
		CLUSTERSH=$(cat $CLUSTERCMD)
		SCANFILE=$(echo $CLUSTERSH | grep '\-d .*' -o | awk '{print $2}')
		SUBMITUSER=$(echo $line | awk '{print $8}')
		TOCFILEPATH=$(dirname $(dirname $CLUSTERCMD))"/toc.txt"
		METASCRIPT=$(cat $CLUSTERCMD | grep '_meta.bash' | awk '{ print $1 }')
		CMDARGUMENTS=$(cat $CLUSTERCMD | grep '_meta.bash' | awk -F '>' '{print $1}' | awk '{for(f=2;f<=NF;f++) printf("%s ",$f) }')
			
	    if [ -f $TOCFILEPATH ] ; then
			TOCFILE=$(cat -E $TOCFILEPATH | sed 's/\$/\\n/g')
			PATIENT_ID=$(echo $TOCFILE | grep "Patient ID" | awk '{print $3}')
			PATIENT_NAME=$(echo -e $TOCFILE | grep "Patient Name" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')			
			PATIENT_AGE=$(echo -e $TOCFILE | grep "Patient Age" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			PATIENT_SEX=$(echo -e $TOCFILE | grep "Patient Sex" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			PATIENT_BIRTHDAY=$(echo -e $TOCFILE | grep "Patient Birthday" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			IMAGE_SCAN_DATE=$(echo -e $TOCFILE | grep "Image Scan-Date" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			SCANNER_MANUFACTURER=$(echo -e $TOCFILE | grep "Scanner Manufacturer" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			SCANNER_MODEL=$(echo -e $TOCFILE | grep "Scanner Model" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			SOFTWARE_VER=$(echo -e $TOCFILE | grep "Software Ver" | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//')
			SCANNAME=$(echo -e $TOCFILE | grep $SCANFILE | awk '{$1="";$2="";print}' | sed -e 's/^[ \t]*//' | tr -d "<>")
								
			echo -e "<ClusterJob>"
			echo -e "    <Command>$(echo_stripped $CLUSTERCMD)</Command>"
			echo -e "    <Arguments>$(echo_stripped $CMDARGUMENTS)</Arguments>"
			echo -e "    <MetaScript>$(echo_stripped $METASCRIPT)</MetaScript>"
			echo -e "    <Date>$(echo_stripped $DATE)</Date>"
			echo -e "    <User>$(echo_stripped $SUBMITUSER)</User>"
			echo -e "    <PatientID>$(echo_stripped $PATIENT_ID)</PatientID>"
			echo -e "    <PatientName>$(echo_stripped $PATIENT_NAME)</PatientName>"
			echo -e "    <PatientAge>$(echo_stripped $PATIENT_AGE)</PatientAge>"
			echo -e "    <PatientSex>$(echo_stripped $PATIENT_SEX)</PatientSex>"
			echo -e "    <PatientBirthday>$(echo_stripped $PATIENT_BIRTHDAY)</PatientBirthday>"
			echo -e "    <ImageScanDate>$(echo_stripped $IMAGE_SCAN_DATE)</ImageScanDate>"
			echo -e "    <ScannerManufacturer>$(echo_stripped $SCANNER_MANUFACTURER)</ScannerManufacturer>"
			echo -e "    <ScannerModel>$(echo_stripped $SCANNER_MODEL)</ScannerModel>"
			echo -e "    <SoftwareVer>$(echo_stripped $SOFTWARE_VER)</SoftwareVer>"
			echo -e "    <ScanName>$(echo_stripped $SCANNAME)</ScanName>"
			echo -e "    <JobId>$curLine</JobId>"
			echo -e "</ClusterJob>"
		fi
	fi
done
	
