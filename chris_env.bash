# CHRIS -- CHildren's Research Imaging System
#
# bash env settings file
#
# This file configures several environment variables that
# are accessed by components of the CHRIS system.
#
# Typical usage is to explicitly source this file by any CHRIS
# subsystem script, i.e.
#
#       source /some/path/chris_env.bash
#
# Customization should only need to set the CHRIS_DICOMROOT var and
# the scripts var
#
#

# The name of this CHRIS instance. Used on web front end and in any emails
# communicated to end users by the system.
export CHRIS_NAME=CHRIS

# Admin user(s) of the CHRIS deployment -- comma separated if multiple
# admins
export CHRIS_ADMINUSERS=rudolph.pienaar@childrens.harvard.edu

# Root dir of DICOM packer subsystem -- this is the main directory housing
# everything relevant to CHRIS
export CHRIS_DICOMROOT=/chb/users/dicom

# Mail binary location
export CHRIS_MAIL=/usr/bin/mail

# CHRIS script storage location
export CHRIS_SCRIPTPATH=${CHRIS_DICOMROOT}/repo/trunk/scripts

# FreeSurfer environment sourcing script: 
export FSSOURCE=${CHRIS_SCRIPTPATH}/chris-fsdev

# Webpage address
export CHRIS_WEBSITE=http://durban.tch.harvard.edu

#
# +----- You shouldn't need to set anything below this line: -----------+
# |     |       |       |       |       |       |       |       |       | 
# V     V       V       V       V       V       V       V       V       V

# The CHRIS_ETC directory contains scripts and files relevant mostly to the 
# DICOM reception and unpacking of data.
export CHRIS_ETC=${CHRIS_DICOMROOT}/etc

# When called from a launchctl process or xinet.d, this script does not
# have a full path, hence we need to specify it here.
export PATH=/usr/bin:/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/games:/etc:/usr/etc:/usr/bin/X11:/usr/X11R6/bin:/opt/gnome/bin:/opt/local/bin:/sw/bin:$PATH

# storescp binary
export CHRIS_STORESCP=$(type storescp | head -n 1 | awk '{print $3}')
export CHRIS_DCMRENAME=${CHRIS_ETC}/dcm_rename

# Location of DICOM Dictionary used by DCMTK. This depends somewhat on
# architecture:
case "$OS"
in 
        "Darwin")       export CHRIS_DCMDICTPATH=/opt/local/lib/dicom.dic     ;;
        "Linux")        export CHRIS_DCMDICTPATH=/usr/share/dcmtk/dicom.dic   ;;
esac

# Location of DICOM data path where the storescp-based litener will
# output its intermediate dicom files
export CHRIS_DCMDATAPATH=${CHRIS_DICOMROOT}/incoming

# Location of whether the incoming DICOM data will ultimately
# be stored after initial processing
export CHRIS_SESSIONPATH=${CHRIS_DICOMROOT}/files

# Location where logs of incoming DICOM receptions will be written
export CHRIS_LOGDIR=${CHRIS_DICOMROOT}/log

# Application Entity Title for storescp listener
export CHRIS_AETITLE=CHRIS

# Location of DTK matrices
export DSI_PATH=${CHRIS_DICOMROOT}/dtk/matrices/

# Source FreeSurfer env
source $FSSOURCE > /dev/null

export PATH=$PATH:${CHB_SCRIPTPATH}:${FSLDIR}:${FSLDIR}/bin

