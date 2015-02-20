#!/bin/bash

################################################################################
# @see README.md
################################################################################

# Do not proceed on error
set -e

################################################################################
# Handle input
################################################################################

# The first argument will be our remote.
if [ "$1" == "" ]
then
  echo "No remote given."
  exit
elif ! git ls-remote $1 &>/dev/null
then
  echo "Remote '$1' does not exist."
  exit
else
  echo "# Remote: '$1'"
  STAGING_REMOTE="$1"
fi

# The second argument will be the remote branch.
if [ "$2" == "" ]
then
  echo "No remoteBranch given."
  exit
else
  echo "# Remote branch '$STAGING_REMOTE/$2'"
  STAGING_REMOTE_BRANCH="$2"
fi

# The third argument will be our source branch.
if [ "$3" == "" ]
then
  echo "No sourceBranch given."
  exit
elif [ "$(git show-ref $3)" == "" ]
then
  echo "Source branch '$3' does not exist."
  exit
else
  echo "# Source branch '$3'"
  echo "Processing branch '$3' ..."
  SOURCE_BRANCH="$3"
fi

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
