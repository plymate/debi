#!/bin/bash
#
# Usage:  DEBuploadV2.sh SiteNum StartDateTime RunTime Interval FilePRE Gsub
#	    This is the only required argument
#	    These are optional arguments
#		SiteNum= the site number you are given for your Pi location/device
#		StartDateTime= time to start in YYYY/MM/DD HH:MM:SS format or now to start immediatly
#		RunTime= number of minutes to capture exposures
#		Interval= number of seconds between exposures
#		FilepPRE= String prefix for file names such as initials klc, etc.
#		Gsub= Subdirectory on the Google drive
#
#
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
# Default values
  if [ $1 == "?" ]
  then
    echo "Usage:  DEBuploadMEu.sh LDrive SiteNum Exposure Gain StartDateTime RunTime Interval FilePRE RcloneADD Gsub"
    echo "SiteNum= the site number you are given for your Pi location/device"
    echo "StartDateTime= time to start in YYYY/MM/DD HH:MM:SS format or now to start immediatly"
    echo "RunTime= number of minutes to capture exposures"
    echo "Interval= number of seconds between exposures"
    echo "FilepPRE= String prefix for file names such as initials klc, etc."
    echo "sub= Subdirectory on the Google drive. Default if left blank is LiveTests directory"

  else
#*********** These are the default values for the commandline variables, Change to match your setup  **********
    SiteNum=1
#  Exposures, last exposure is what goes to Google Drive
    Exposure=(500 4000 33333 1000000 33333)
    GAIN=16
    StartDateTime="now"
    RunTime=5
    Interval=15
    FilePRE="klc"
    Gsub=""
    Name="Kevin Cobble"
    FNum="4/1"
    FLen="75/1"
    GPS=true
    imgsize="-w 1040 -h 760"		# jpeg image size  Set to "" for default size
#************ These are the values for if you have a GPS (set to true) and for your local name for the Rclone address*
# If you do not have a GPS enter your coordinates below Note the format as "Degrees/1,Minutes/1,Seconds/100" 
#     with seconds *100 to get the decimal so 30.88 becomes 3088/100
# Similar for Altitude with Altitude *10 to get tenths of meters so 181.6 meters becomes 1816/10
    Lat="33/1,9/1,3088/100"
    Long="96/1,29/1,1944/100"
    Alt="1816/10"		#meters
    RcloneADD="zfield"
# Local subdirectory to store images in
    Lsub="klctest"

# ***************** End Default values ************************************************************************
  if [[ ! -z $1 ]];
  then
    SiteNum=$1
  fi

  if [[ ! -z $2 ]];
  then
    StartDateTime=$2
  fi

  if [[ ! -z $3 ]];
  then
    RunTime=$3
  fi

  if [[ ! -z $4 ]];
  then
    Interval=$4
  fi

  if [[ ! -z $5 ]];
  then
    FilePRE=$5
  fi
  if [[ ! -z $6 ]];
  then
    Gsub=$6
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
 echo "Write RAW file to Local Drive jpeg to Google Drive"
 echo "Local Subdirectory= " $Lsub
 echo "Site Number= " $SiteNum
 echo "Start time entered "$StartDateTime
 StartTime=$(date -u -d "$StartDateTime" +%s )
 ENDTIME=$((StartTime+RunTime*60))
 TZ=UTC printf "%(StartTime= %m/%d/%Y %T %Z)T\n" $StartTime 
 TZ=UTC printf "%(ENDTIME= %m/%d/%Y %H:%M:%S %Z)T\n" $ENDTIME 
 echo "Time between exposures = " $Interval "Sec."
 echo "Exposure  = " ${Exposure[1]} "usec"
 echo "GAIN = " $GAIN
 echo "File Prefix = " $FilePRE
 echo "GPS=" $GPS

   echo "Google write delay= " $SiteNum"00msec"
   echo "Google Subdirectory=" $Gsub
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
   Ecount=0
#  Delay until Start Time
#
   while [ $TIME -lt $StartTime ]; do
    sleep 1
    TIME=$(date +%s)
   done
   while [ $Ecount -lt 4 ]; do
   DATE=$(date -u +%Y%m%d)
   TIME=$(date -u +%H%M%S%3N)
   RFILENAME=$FilePRE"_S"$SiteNum"_G"$GAIN"_E"${Exposure[$Ecount]}"_T"$DATE"_"$TIME"-RAW.jpg"
   JFILENAME=$FilePRE"_S"$SiteNum"_G"$GAIN"_E"${Exposure[$Ecount]}"_T"$DATE"_"$TIME".jpg"
   echo "Filename= " $FILENAME "Start Time-" $(date +%H\:%M\:%S)
   StartTime=$((StartTime+Interval))
   printf "%(Next Exp. Time= %m/%d/%Y %H:%M:%S)T\n" $StartTime
   GetImage $GAIN ${Exposure[$Ecount]} $RFILENAME "-r" ""
#   GetImage $GAIN ${Exposure[$Ecount]} $JFILENAME "" ""
   let Ecount=Ecount+1
  done
    Ncount=0
    while [ $Ncount -lt $Ndy ];do
      sleep 0.1
      let Ncount=Ncount+1
    done
    JFILENAME=$FilePRE"_S"$SiteNum"_G"$GAIN"_E"${Exposure[4]}"_T"$DATE"_"$TIME".jpg"
    GetImage $GAIN ${Exposure[4]} $JFILENAME "" "$imgsize"
    rclone copyto ~/$Lsub/$JFILENAME $RcloneADD:/$Gsub/$JFILENAME
    echo "File write complete" $(date +%H:%M:%S) "("$(date -u +%H:%M:%S) "UTC)"
    echo "*******************************************************"
 done
 fi
#
# end of procedure

