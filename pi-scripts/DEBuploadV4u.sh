#!/bin/bash
#
# Usage:  DEBuploadV4.sh LDrive SiteNum Exposure Gain StartDateTime RunTime Interval FilePRE Gsub
#	    This is the only required argument
#	    These are optional arguments
#		LDrive = 0 for local storage only jpeg only, 1 for local jpeg only and Google Drive, 
#		         2 for local jpeg+raw only, 3 for jpeg+raw and jpeg sent to google drive "?" for help
#		SiteNum= the site number you are given for your Pi location/device
#		Exposure= Exposure time in usec
#		Gain= Analog Gain 0-16
#		StartDateTime= time to start in YYYY/MM/DD HH:MM:SS format or now to start immediatly
#		RunTime= number of minutes to capture exposures
#		Interval= number of seconds between exposures
#		FilepPRE= String prefix for file names such as initials klc, etc.
#		Gsub= Subdirectory on the Google drive
#
# Examples: 
#	DEBuploadV4.sh 0
#	 Starts now, saving to the local directory only.  The rest are from the default values: Site number=1 file prefix is klc, uses subdirectories home/pi/klctest as well as the klctest subdirectory on Google drive
#	 goes for 5 minute, takes images every 15 seconds using a 4000usec exposure and gain of 1
#
#	DEBuploadV4.sh 3 8
#	 Starts now, saving both jpeg and raw to the local directory and uploading the jpg to the google drive.
#        The rest are from the default values: Site number=1 file prefix is klc, uses subdirectories home/pi/klctest as well as the klctest subdirectory on Google drive
#	 goes for 5 minute, takes images every 15 seconds using a 4000usec exposure and gain of 1
#
#	DEBuploadV4sh 1 8 4000 1 now 1 15 klc zfield klctest
#	 Starts now, Site number=8, file prefix is klc, uses subdirectories home/pi/klctest as well as the klctest subdirectory on Google drive
#	 goes for 1 minute, takes images every 15 seconds using a 4000usec exposure and gain of 1
#
#       DEBuploadV4.sh 3 8 4000 1 "2021/11/7 14:20:00" 1 15 klc klctest
#	 Puts raw and jpg files in the Local Directory and uploads the jpg file to the DEB directory under klctest
#	 Starts at "14:20:00 on 2021/11/7" (must use double quotes around time), file prefix is klc, 
#	 Site number = 8,goes for 1 minute, takes images every 15 seconds using a 4000usec exposure and gain of 1
#

#*********** These are the default values for the commandline variables, Change to match your setup  **********
# Default values
    LDrive=0
    SiteNum=1
    Exposure=4000
    GAIN=1
    StartDateTime="now"
    RunTime=5
    Interval=15
    FilePRE="klc"
#    imgsize="-w 1040 -h 760"		# will make the jpeg image 1040 x 760
    imgsize=""				# will make the jpeg image the default size
#   Local subdirectory to store images in
    Lsub="klctest"
#   ***************** Be sure to put your rclone name that you use to copy to the DEB Google Drive in RcloneADD *****************
    RcloneADD="DEB"
    Gsub="klctest"			# Subdirectory on the Google drive to write to. If "//" will write to LiveTests directory
    Name="Kevin Cobble"
    FNum="4/1"				# this is f/4.  For 5.6 change to "56/10"
    FLen="75/1"
#************ These are the values for if you have a GPS (set to true) and for your local name for the Rclone address*
# If you do not have a GPS enter your coordinates below Note the format as "Degrees/1,Minutes/1,Seconds/100" 
#     with seconds *100 to get the decimal so 30.88 becomes 3088/100
# Similar for Altitude with Altitude *10 to get tenths of meters so 181.6 meters becomes 1816/10
    GPS=true
    Lat="33/1,9/1,3088/100"
    Long="96/1,29/1,1944/100"
    Alt="1816/10"		#meters

# ***************** End Default values ************************************************************************
  
#*********** Functions  ***************************************************************************************************

# Call: GetImage(GAIN Exposure Filename Rawmode Optns)
  GetImage () {
       echo "GetImage file name=" $3
       echo "GetImage Exposure=" $2
       raspistill -t 50 -md 3 -bm -ex off -ag $1 -ss $2 -q 100 $GPSst -x EXIF.FNumber=$FNum \
 	-x EXIF.FocalLength=$FLen -x EXIF.DigitalZoomRatio=$GAIN"/1" \
 	-x EXIF.ImageUniqueID="$Name" -x EXIF.MaxApertureValue=$SiteNum"/1" $4 $5 -o $3
 }

#************ Main Program Starts Here *************************************************************************************
  if [ $1 == "?" ]
  then
    echo "Usage:  DEBuploadV4.sh LDrive SiteNum Exposure Gain StartDateTime RunTime Interval FilePRE RcloneADD Gsub"
    echo "LDrive = 0 for local storage only jpeg only, 1 for local jpeg only and Google Drive,"
    echo "         2 for local jpeg+raw only, 3 for jpeg+raw and jpeg sent to google drive "?" for help"
    echo "SiteNum= the site number you are given for your Pi location/device"
    echo "Exposure= Exposure time in usec"
    echo "Gain= Analog Gain 0-16"
    echo "StartDateTime= time to start in YYYY/MM/DD HH:MM:SS format or now to start immediately"
    echo "RunTime= number of minutes to capture exposures"
    echo "Interval= number of seconds between exposures"
    echo "FilepPRE= String prefix for file names such as initials klc, etc."
    echo "sub= Subdirectory on the Google drive. Default if left blank is LiveTests directory"

  else
if [[ ! -z $1 ]];
  then
    LDrive1=$1
  fi
  RAw=$(( LDrive1 / 2))
#  echo "RAw=" $RAw
  LDrive=$(( LDrive1 - RAw *2))
#  echo "LDrive=" $LDrive

  if [[ ! -z $2 ]];
  then
    SiteNum=$2
  fi

  if [[ ! -z $3 ]];
  then
    Exposure=$3
  fi

  if [[ ! -z $4 ]];
  then
    GAIN=$4
  fi

  if [[ ! -z $5 ]];
  then
    StartDateTime=$5
  fi

  if [[ ! -z $6 ]];
  then
    RunTime=$6
  fi

  if [[ ! -z $7 ]];
  then
    Interval=$7
  fi

  if [[ ! -z $8 ]];
  then
    FilePRE=$8
  fi
  if [[ ! -z $9 ]];
  then
    Gsub=$9
  fi

#  Display arguments for the data collect as a check
 Ndy=$(( SiteNum + 1))
 Name=$Name" Site-"$SiteNum
 RwMode="-r"
 if [ $GPS = true ]
 then
    GPSst="-gps"
 else
    GPSst="-x GPS.GPSLatitude="$Lat" -x GPS.GPSLongitude="$Long" -x GPS.GPSAltitude="$Alt
 fi
    echo "GPS string= " $GPSst
 echo "*******************************************************"
 echo "Name=" $Name
 if [ $RAw -gt 0 ]
 then
    echo "Write RAW file to Local Drive"
 else
    echo "Write jpeg only file to Local Drive"
 fi

 if [ $LDrive -gt 0 ]
 then
   echo "Store images to local drive and Google Drive"
 else
   echo "Store images to local drive Only"
 fi
 echo "Local Subdirectory= " $Lsub
 echo "Site Number= " $SiteNum
 echo "Start time entered "$StartDateTime
 StartTime=$(date -u -d "$StartDateTime" +%s )
 ENDTIME=$((StartTime+RunTime*60))
 TZ=UTC printf "%(StartTime= %m/%d/%Y %T %Z)T\n" $StartTime 
 TZ=UTC printf "%(ENDTIME= %m/%d/%Y %H:%M:%S %Z)T\n" $ENDTIME 
 echo "Time between exposures = " $Interval "Sec."
 echo "Exposure  = " $Exposure "usec"
 echo "GAIN = " $GAIN
 echo "File Prefix = " $FilePRE
 echo "GPS=" $GPS

 if [ $RAw -eq 1 ]
 then
   echo "Raw File saved"
 else
   echo "Raw File NOT saved"
 fi

 if [ $LDrive -eq 1 ]
 then
   echo "Google write delay= " $SiteNum"00msec"
   echo "rclone ID for write to DEB Google Drive=" $RcloneADD":/"$Gsub
#   echo "Google Subdirectory=" $Gsub
 fi
 echo "*******************************************************"
#
# Set current time
#
TIME=$(date +%s)
# 
# Delay until Start Time
#
while [ $TIME -lt $StartTime ]; do
  sleep 1
  TIME=$(date +%s)
done
#
# set to ~/test directory locally and begin taking pictures (Change as desired)
# 
  mkdir ~/$Lsub -p
  cd ~/$Lsub
#
# Picture file names will be formatted as: FilePRE_S(Site number)_G(gain)_E(Exposure)_TYYYYMMDD_HHMMSSNNN.jpg, adjust as desired
# in the raspistill and rclone commands
# 

#************************************Main Program Loop *****************************************************************
 while [ $TIME -lt $ENDTIME ]; do
# Delay until Start Time
#
  while [ $TIME -lt $StartTime ]; do
    sleep 1
    TIME=$(date +%s)
  done
  DATE=$(date -u +%Y%m%d)
  FTIME=$(date -u +%H%M%S%3N)
  RFILENAME=$FilePRE"_S"$SiteNum"_G"$GAIN"_E"$Exposure"_T"$DATE"_"$FTIME"-RAW.jpg"
  JFILENAME=$FilePRE"_S"$SiteNum"_G"$GAIN"_E"$Exposure"_T"$DATE"_"$FTIME".jpg"
  StartTime=$((StartTime+Interval))
  printf "%(Next Exp. Time= %m/%d/%Y %H:%M:%S %Z)T\n" $StartTime
    if [ $RAw -eq 1 ]
    then
    echo "Raw Filename= "$RFILENAME
      GetImage $GAIN $Exposure $RFILENAME "-r" ""
      sleep 0.2
    fi
  echo "JPEG Filename= "$JFILENAME
  GetImage $GAIN $Exposure $JFILENAME "" "$imgsize"
  if [ $LDrive -eq 1 ]
  then
    Ncount=0
    while [ $Ncount -lt $Ndy ];do
      sleep 0.1
      let Ncount=Ncount+1
    done
    rclone copyto ~/$Lsub/$JFILENAME $RcloneADD:/$Gsub/$JFILENAME
  fi
  echo "File write complete" $(date +%H:%M:%S) "("$(date -u +%H:%M:%S) "UTC)"
  echo "*******************************************************"
 done
 fi
#
# end of procedure

