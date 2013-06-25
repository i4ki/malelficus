#!/bin/bash
today=$(date '+%d_%m_%y')
echo "* Making a local backup to LaCie..."
tar czPf /Volumes/LaCie/backups/tjstein.com_"$today".tar.gz `pwd`
echo "* Backed up!"
echo "* Removing all backups over 60 days old..."
MaxFileAge=60
find /Volumes/LaCie/backups/ -name '*.gz' -type f -mtime +$MaxFileAge -exec rm -f {} \;
echo "* Done!"
echo "* Copying to Amazon S3..."
s3cmd --rr put /Volumes/LaCie/backups/tjstein.com_"$today".tar.gz s3://tjstein.com-backups >> /dev/null
echo "* Copying finished!"