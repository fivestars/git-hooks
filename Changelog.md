# Changelog

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
