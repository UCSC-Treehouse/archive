#!/usr/bin/env python
"""
Output a list of all s3 keys in the Treehouse archive bucket corresponding
to secondary bam files older than 180 days. This assumes the bucket
has been setup to generate S3 inventory files and looks for the latest one
to identify files to expire. Note that this may mean that the objects lists
have already been expired if a prior script is run before a new inventory
is generated. See S3 inventory for more details.
"""
import os
import io
from datetime import datetime, timedelta
import argparse
import pandas as pd
import boto3

parser = argparse.ArgumentParser(
    description="Save a list of S3 objects to expire as per Treehouse Storage Policy")
parser.add_argument("--bucket", default="archive-treehouse-ucsc-edu",
                    help="S3 bucket")
parser.add_argument("--profile", default="treehouse",
                    help="S3 credentials profile name")
parser.add_argument("--output", default="expire",
                    help="Output path for files to expire list")
args = parser.parse_args()

session = boto3.Session(profile_name=args.profile)
s3 = session.client("s3")

# Download the latest S3 inventory file
response = s3.list_objects_v2(Bucket=args.bucket,
                              Prefix="inventory/archive-treehouse-ucsc-edu/all/data/")

# Exclude the parent directory file is / which is zero bytes
files = [f for f in response["Contents"] if f["Size"] > 0]

# Sort by date and load the latest into a dataframe
latest = sorted(files, key=lambda obj: obj["LastModified"])[-1]["Key"]

obj = s3.get_object(Bucket=args.bucket, Key=latest)
inventory = pd.read_csv(io.BytesIO(obj['Body'].read()), compression="gzip",
                        names=["bucket", "key", "version", "latest", "?",
                               "size", "created", "etag", "class", "??", "???", "encryption"],
                        parse_dates=["created"])

# Find secondary bams older than 180 days
cutoff = datetime.now() - timedelta(days=180)
secondary_bams = inventory[(inventory.created < cutoff) &
                           (inventory.key.str.contains("downstream\/.+?\.bam"))]

print("S3 secondary BAMs older than 180 days:")
print(secondary_bams.shape[0])
print("{:.3f}\ttotal".format(secondary_bams["size"].sum() / 10**12))

# Save the list of s3 paths to bams to delete
paths_to_delete = "s3://" + args.bucket + "/" + secondary_bams["key"].astype(str)
paths_to_delete.to_csv(os.path.join(args.output, "s3_secondary_bams.txt"),
                       index=False, header=False)
