#!/bin/bash

################################################################################
# This script is for adjusting the staging branch to a specific branch content.
# The resulting branch will likely not share the history with the given branch,
# but will ensure all files are present in the same state as in the original
# branch.
#
# This approach is needed to ensure we can use the a git based hosting with a
# fixed branch, to rollout and test multiple different branches. In that case
# we have got a single staging branch to deploy to. That branch only will get
# "diff commits" that changes the file state to a defined state of the given
# branch.
#
# Usage
# -----
# 1.  change STAGING_REMOTE and STAGING_REMOTE_BRANCH to your needs
# 2.  execute "bash staging.sh mybranchname"
#
# Features
# --------
# - Stashes the current uncommited changes of the current branch, and switches
#   back to that state, after deploying the commit diff.
#
# Arguments
# ---------
# 1: Name of the branch: e.g. "mybranch" or "origin/66-hello"
#    "bash staging.sh origin/66-hello"
#
# Options
# -------
# - currently none -
#
################################################################################

# Do not proceed on error
set -e

################################################################################
# Handle input
################################################################################

# The first argument will be our source branch.
if [ "$1" == "" ]
then
  echo "No branch given."
  exit
elif [ "$(git show-ref $1)" == "" ]
then
  echo "Branch '$1' does not exist."
  exit
else
  echo "Processing branch '$1' ..."
  SOURCE_BRANCH="$1"
fi

################################################################################
# Basic hardcoded variables
# @todo: provide arguments and/or options
################################################################################
STAGING_REMOTE="staging"
STAGING_REMOTE_BRANCH="master"

################################################################################
# Processing
################################################################################

# Get the current branch, so we can switch back later.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Echo the command before executing it.
set -x

# First collect the latest code from remote
git fetch $STAGING_REMOTE

TEMP_BRANCH=temp$(date +%s)

# Stash the current changes (if some present), before switching branch.
if [ "$(git status -s)" == "" ]
then
  STASHED=0
else
  STASHED=1
  git stash save --include-untracked "Before stage $TEMP_BRANCH"
fi

# We build a temporarry local branch for the remote branch.
echo "Building temporary branch: $TEMP_BRANCH"
git checkout -b $TEMP_BRANCH "$STAGING_REMOTE/$STAGING_REMOTE_BRANCH"

# Create diff to the source branch
# - reverted, because we want to add the diff to this branch
# - full-index and binary flag are for providing complete information for even
#   applying binary changes
git diff --full-index --binary -R $SOURCE_BRANCH > "$TEMP_BRANCH.patch"

# Get sha from source branch.
SOURCE_SHA=$(git rev-parse "$SOURCE_BRANCH")

# We might have some whitespace problems, when applying diffs, so we make sure
# warnings to not kill our processing.
git apply --whitespace=nowarn "$TEMP_BRANCH.patch"

# After applying the patch, we remove the patchfile, so it will not be part of
# our diff commit.
rm "$TEMP_BRANCH.patch"

# Stage all files and commit it.
git add -A
git commit -m "Staging: $SOURCE_BRANCH (sha: $SOURCE_SHA)"

# And push it back.
git push $STAGING_REMOTE HEAD:$STAGING_REMOTE_BRANCH

# Switch back to the further branch.
git checkout $CURRENT_BRANCH
# Apply stashed changes back to working directory.
if [ $STASHED == 1 ]
then
  git stash pop
fi

# Finally we delete our temporary branch.
git branch -D $TEMP_BRANCH
