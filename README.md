# archive
Scripts facilitating the [Treehouse Storage Management](https://docs.google.com/document/d/1otNDUQIGOY4zqPBAp4OzUnhXAmt1FHrJjqjA2jsUBrI/edit?usp=sharing)

See policy.pdf for an archived version of the policy as well as the S3 configuration files to understand how the local and S3 bucket work together to implement the policy.

archive.sh should be run on a regular basis to sync the local archive up to S3 as well as generate a list of files that can be expired from the local as well as S3 bucket. Some of the files expire automatically from the S3 bucket via the life cycle policy while others much be programmatically identified (see archive.py) as the S3 life cycle policy can only be scoped to a prefix.
