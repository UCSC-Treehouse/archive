#!/bin/bash

# Backup to S3 and then generate several lists of files both loca
# and on S3 to be deleted as per the Treehouse Storage Management
# policy. Actual deletion is a separate step for safety.

archive=/pod/pstore/groups/treehouse/archive
bucket=archive-treehouse-ucsc-edu

mkdir -p expire

echo "Total local archive size:"
du -sh $archive 

echo "Backing local archive up to s3..."
aws s3 sync --no-follow-symlinks $archive s3://archive-treehouse-ucsc-edu/ > expire/archived.txt
echo "Total number of files backed up:"
wc -l < expire/archived.txt

echo "Identifying S3 files to expire..."
python archive.py --bucket $bucket

echo "Local primary files older than 90 days:"
find $archive/primary/* -type f -mtime +90 > expire/local_primary.txt
wc -l < expire/local_primary.txt
du -ch `cat expire/local_primary.txt` | tail -1
 
find $archive/downstream/* -type f -name "*.bam" -mtime +90 > expire/local_secondary_bams.txt
echo "Local secondary BAMs older than 90 days:"
wc -l < expire/local_secondary_bams.txt
du -ch `cat expire/local_secondary_bams.txt` | tail -1