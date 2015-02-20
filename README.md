# staging

A helper script to deploy a specific code state from one git in another git repo.


Bash script for deploying the exact state of a given branch to a remote branch. This is done by using "diff commits".

## Usage:

1. change `STAGING_REMOTE` and `STAGING_REMOTE_BRANCH` to your needs
2. execute `bash staging.sh mybranchname` to commit that branch to the _staging remote branch_

## Description

This script is for adjusting the staging branch to a specific branch content.
The resulting branch will likely not share the history with the given branch,
but will ensure all files are present in the same state as in the original
branch.

This approach is needed to ensure we can use the a git based hosting with a
fixed branch, to rollout and test multiple different branches. In that case
we have got a single staging branch to deploy to. That branch only will get
"diff commits" that changes the file state to a defined state of the given
branch.

### Features

* Stashes the current uncommited changes of the current branch, and switches
   back to that state, after deploying the commit diff.

### Arguments

1. Name of the branch: e.g. "mybranch" or "origin/66-hello"
    "bash staging.sh origin/66-hello"

### Options

- currently none -