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

## Installation

### via composer

`composer global require derhasi/staging`

### Manually

````
curl -O https://raw.githubusercontent.com/derhasi/staging/master/staging
chmod u+x staging
mv staging /usr/local/bin/staging
```

## Usage:

```
staging [-hv] {remote} {remoteBranch} {sourceBranch}"
```

The command creates a commit on the `remoteBranch` with the exact code state of the `sourceBranch`.

### Arguments

1. `{remote}`: Name of the remote repository to push the code to. Example: `origin`
2. `{remoteBranch}`: Name of the remote branch to push the code to. Example: `master`
3. `{sourceBranch}`: Name of the branch to get the code from. May be a local or a remote branch reference.
   Examples: `mybranch` or `origin/66-hello`

### Options

* `-h`: Shows help message for the command
* `-v`: Provides verbose output
* `-m "Custom commit message"`: Replaces the default message (`Staging: [source branch] (sha: [source sha])`) with the
  given custom one

### Features

* Stashes the current uncommited changes of the current branch, and switches back to that state, after deploying the
  commit diff.
  
## Example

You have one stage environment available, where you are only allowed to push code via git. The corresponding git
repository is located at `https://stage.example.com/site.git`. The branch to deploy to is `master`. 
Now, you have got several branches in development (`123-story`, `124-event`, `125-contact`) you want to test on that
staging environment. You can do that, one after another using _staging_.

First, add your stage remote to your local repo: `git remote add stage https://stage.example.com/site.git`.

Now you can deploy the code to your stage from any arbitrary branch.

Let's start with the first: `staging stage master 123-story`.
After that `git diff 123-story stage/master` would show no difference.

With executing `staging stage master 124-event`, you will get the same for `git diff 123-story stage/master`.

You even can enter `staging stage master origin/125-contact` to directly work with the a remote branch instead of a
local branch.
