# Changelog

## 1.2.0 - Allow unticketed work, manual updates, and access to included lib functions
*Date:* 2019-02-08

*Tags:*  `v1.2.0`

### Features
- Exporting GIT_HOOKS_LIB directory to user hook scripts
- Added `git hooks update` command to allow manual syncing
- Allow for unticketed work when using jira hooks
- Added some core functions to determine what kind of git operation is underway(commit, merge, cherry-pick...)

### Changes
- ${c_prompt} and ${c_warning} are now available to user hook scripts
- Wrapped some update code into reusable functions
- Skip `commit-msg/jira-format` when possible (merge, non-branch commit, unticketed work)
- Skip `pre-commit/jira-branch-name` when possible (not a new commit in progress)
- Skip `pre-commit/jira-protect-branch` when possible (not a new commit in progress)

### Fixes
- Don't print branch name in `pre-commit/jira-protect-branch`

## 1.1.1 - Jira hooks fixes
*Date:* 2019-01-14

*Tags:*  `v1.1.1`

### Fixes
- Fixed some issues in the Jira hooks that prevented the initial commit in a new repository

## 1.1.0 - Global hooks support and better Jira/Sentry integration
*Date:* 2019-01-13

*Tags:*  `v1.1.0`

### Features
- Added Global git hooks support
- The `prepare-commit-msg/jira` hook now pre-populates the message with the contents of the associated Jira ticket (derived from the branch name)
- Added `commit-msg/add-sentry-issues` to append `Fixes ...` lines if the Jira tickets in the commit message have associated Sentry issues
- Added `sync-collection` and `list-collections` commands

### Changes
- Limit collection update checks to once-per-week.
- Split the `prepare-commit-msg/template` into two hooks: `prepare-commit-msg/cached` and `prepare-commit-msg/subject`
- Added output to `prepare-commit-msg` hooks when they are skipped due to commit message type

### Fixes
- Fix is_protected_branch on mac
- README.md improvements

## 1.0.0 - Initial release
*Date:* 2018-09-18

*Tags:* `v1.0.0`
