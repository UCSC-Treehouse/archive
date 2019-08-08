# archive
Scripts facilitating the [Treehouse Storage Management](https://docs.google.com/document/d/1otNDUQIGOY4zqPBAp4OzUnhXAmt1FHrJjqjA2jsUBrI/edit?usp=sharing)

See policy.pdf for an archived version of the policy as well as the S3 configuration files to understand how the local and S3 bucket work together to implement the policy.

archive.sh should be run on a regular basis to sync the local archive up to S3 as well as generate a list of files that can be expired from the local as well as S3 bucket. Some of the files expire automatically from the S3 bucket via the life cycle policy while others much be programmatically identified (see archive.py) as the S3 life cycle policy can only be scoped to a prefix.

After running there will be three lists of files in the expire/directory:

* local_primary.txt: Primary original and derived files older then 90 days

* local_secondary_bams.txt: Aligned bams in downstream output,primarily from RNASeq and Fusion, that are older the 90 days.

* s3_secondary_bams.txt: Secondary bams in S3/Glacier older then 180 days

To actually delete all the files listed in each of these outputs:

```
xargs rm < expire/local_primary.txt
xargs rm < expire/local_secondary_bams.txt
for f in $(cat expire/s3_secondary_bams.txt) ; do aws --profile treehouse s3 rm "$f"; done
```

The expire/ directory will additionally contain an `archived-201xxxxxTxxxxxx.txt` file labeled with the date of the run and listing what files were uploaded to S3.

This file can be very large (100s of Mb) due to the "Completed ... with ... remaining" spam. To reduce to a reasonable size:
`sed -e 's/.*upload: /upload: /' < $archivedFileName > $archivedFileName.small`

## Setup gotchas

- You need a `[treehouse]` profile in your `~/.aws/credentials` file with an `aws_access_key_id` and `aws_secret_access_key`
that have the appropriate permissions to modify the treehouse bucket.

- Your python3 needs to be at least 3.6 and have pandas and boto3 installed. Use a virtualenv for convenience:
```
virtualenv -p python3 aws_env
source aws_env/bin/activate
pip install pandas boto3
```
