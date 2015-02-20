# staging

A helper script to deploy a specific code state from one git in another git repo.


Bash script for deploying the exact state of a given branch to a remote branch. This is done by using "diff commits".

## Usage:

1. change `STAGING_REMOTE` and `STAGING_REMOTE_BRANCH` to your needs
2. execute `bash staging.sh mybranchname` to commit that branch to the _staging remote branch_
