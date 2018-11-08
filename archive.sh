#!/bin/bash

# Backup to S3 and then generate several lists of files both loca
# and on S3 to be deleted as per the Treehouse Storage Management
# policy. Actual deletion is a separate step for safety.

ARCHIVE=/private/groups/treehouse/archive
BUCKET=archive-treehouse-ucsc-edu
PROFILE=treehouse

DATE=`date +%Y%m%dT%H%M%S`
echo $DATE

mkdir -p expire

echo "Total local archive size:"
du -sh $ARCHIVE 

echo "Backing local archive up to s3..."
aws --profile treehouse s3 sync --no-follow-symlinks $ARCHIVE s3://$BUCKET/ > expire/archived-$DATE.txt
echo "Total number of files backed up:"
wc -l < expire/archived-$DATE.txt

echo "Identifying S3 files to expire..."
python3 archive.py --bucket $BUCKET

echo "Local primary files older than 90 days:"
find $ARCHIVE/primary/* -type f -mtime +90 > expire/local_primary.txt
wc -l < expire/local_primary.txt
du -ch `cat expire/local_primary.txt` | tail -1
 
find $ARCHIVE/downstream/* -type f -name "*.bam" -mtime +90 > expire/local_secondary_bams.txt
echo "Local secondary BAMs older than 90 days:"
wc -l < expire/local_secondary_bams.txt
du -ch `cat expire/local_secondary_bams.txt` | tail -1
