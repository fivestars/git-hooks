# Changelog

## 1.4.0 - General fixes and improvements to the core tool and several hooks
*Date:* 2020-02-18

*Tags:* `v1.4.0`

### Features
*No new features*

### Changes
- `[commit-msg/jira-format]` Don't apply message body formatting rules if tickets was generated from automated tooling ([#30](https://github.com/fivestars/git-hooks/pull/30))
- `[commit-msg/jira-format]` Omit Markdown link syntax from line-length consideration ([#30](https://github.com/fivestars/git-hooks/pull/30))
- `[prepare-commit-msg/jira]` Automatically translate Jira links and `{code}` blocks to their Markdown analogue ([#32](https://github.com/fivestars/git-hooks/pull/32))
- `[prepare-commit-msg/jira]` Do not fold a line to prescribed length if Jira issue was created by an automated integration ([#32](https://github.com/fivestars/git-hooks/pull/32))
- `[pre-commit/jira-branch-name, pre-commit/jira-protect-branch, prepare-commit-msg/subject]` Improved syntax highlighting and CLI output ([#33](https://github.com/fivestars/git-hooks/pull/33))

### Fixes
- Use the correct `$githooks_dir` when running the `git hooks include` command without the `-g` flag ([#31](https://github.com/fivestars/git-hooks/pull/31))
- `[commit-msg/add-sentry-issues]` Correctly extract the Sentry issue link and use it in commit message augmentation ([#34](https://github.com/fivestars/git-hooks/pull/34))


## 1.3.0 - Global sets, list-collection command, sync-collection fixes
*Date:* 2019-02-17

*Tags:* `v1.3.0`

### Features
- Add "global sets" of hooks to allow different repositories to use different sets of global hooks ([#25](https://github.com/fivestars/git-hooks/pull/25))
- Add list-collection command to enumerate and display documentation available for hook scripts in a collection ([#26](https://github.com/fivestars/git-hooks/pull/26))

### Changes
- Update documentation for git-hooks collection hook scripts ([#26](https://github.com/fivestars/git-hooks/pull/26))

### Fixes
- Fix implicit sync-collection to pull the latest collection updates once a week ([#24](https://github.com/fivestars/git-hooks/pull/24))
- Fix function names so sh hook scripts don't error out ([#27](https://github.com/fivestars/git-hooks/pull/27))


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
