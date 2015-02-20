# staging

![travis ci test status](https://api.travis-ci.org/derhasi/staging.svg)

A helper script to deploy a specific code state from one git in another git repo.

Bash script for deploying the exact state of a given branch to a remote branch. This is done by using "diff commits".

This script is for adjusting the staging branch to a specific branch content.
The resulting branch will likely not share the history with the given branch,
but will ensure all files are present in the same state as in the original
branch.

This approach is needed to ensure we can use the a git based hosting with a
fixed branch, to rollout and test multiple different branches. In that case
we have got a single staging branch to deploy to. That branch only will get
"diff commits" that changes the file state to a defined state of the given
branch.

## Usage:

```
./staging [remote] [remoteBranch] [sourceBranch]"
```

The command creates a commit on the `remoteBranch` with the exact code state of the `sourceBranch`.

### Arguments

1. `[remote]`: Name of the remote repository to push the code to. Example: `origin`
2. `[remoteBranch]`: Name of the remote branch to push the code to. Example: `master`
3. `[sourceBranch]`: Name of the branch to get the code from. May be a local or a remote branch reference.
   Examples: "mybranch" or "origin/66-hello"

### Features

* Stashes the current uncommited changes of the current branch, and switches back to that state, after deploying the
  commit diff.
