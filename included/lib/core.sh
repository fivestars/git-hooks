#!/usr/bin/env bash

# Shorthand for common colors (just used for )
red="\\e[0;31m"
b_red="\\e[1;31m"
green="\\e[0;32m"
b_green="\\e[1;32m"
yellow="\\e[0;33m"
b_yellow="\\e[1;33m"
blue="\\e[0;34m"
b_blue="\\e[1;34m"
pink="\\e[0;35m"
b_pink="\\e[1;35m"
cyan="\\e[0;36m"
b_cyan="\\e[1;36m"
c_reset="\\e[0m"

# Themed colors - export these in your shell to override
c_good="${c_good:-${green}}"
c_error="${c_error:-${red}}"
c_prompt="${c_prompt:-${b_cyan}}"
c_action="${c_action:-${cyan}}"
c_value="${c_value:-${yellow}}"

function is_protected_branch () {
    # Fail if branch is not found in .protected,
    # or if that file does not exist, fail if the branch is "master".
    #
    # Return: 1 or 0
    # Stdout: <none>
    # Stderr: <none>

    local protected

    if [[ -f .protected ]];then
        protected="$(xargs <.protected)"
    fi
    protected="${protected:-master}"
    protected="^${protected// /\$\\|\^}\$"

    grep -q "$protected" <<<"$1"
}

function is_valid_branch_name () {
    # Fail if the branch name does not match the expected pattern
    # Examples of valid branch names:
    #    JIRA-1
    #    JIRA-1234
    #    JIRA-1234-some-stuff
    #    myname-JIRA-1234
    #    myname-JIRA-1234-some-stuff
    #
    # Return: 1 or 0
    # Stdout: <none>
    # Stderr: <none>
    grep -q '^\([a-z]\+-\)\?[A-Z]\+-[0-9]\+\(-[a-z0-9]\+\)*$' <<<"$1"
}

function open_uri () {
    # Attempt to open the web browser to the given uri and print the uri to the screen.
    local uri="$1"

    case "$(uname)" in
        CYGWIN*)    cygstart "$uri" ;;
        Darwin)     open "$uri" ;;
        Linux)      ;;
        *)          ;;
    esac

    printf "    ${c_action}%s${c_reset} %s\\n" "Visit:" "$uri"
    #
    # Return: 0
    # Stdout: A message containing the passed in url
    # Stderr: <none>
}

function prompt_with_default_value () {
    # Convenience function for displaying a prompt for input.
    # If a default value is passed in, include that in the prompt but in a different color.
    #
    # Return: 0
    # Stdout: The provided message and the default value in a consistent format
    # Stderr: <none>
    local msg="$1" value="${2:-}"

    if [[ -n "$value" ]]; then
        printf "${c_prompt}%s (${c_value}%s${c_prompt}): ${c_reset}" "$msg" "$value"
    else
        printf "${c_prompt}%s: ${c_reset}" "$msg"
    fi
}

function move_to_branch () {
    # If the provided branch name differs from the current branch, check out that branch instead.
    # The intent is to use this to switch branches during a git pre-commit hook. If asked to do so,
    # delete the previous branch after the switch.
    #
    # Return: 0
    # Stdout: Status and prompt strings
    # Stderr: <none>
    local response branch new_branch="$1"

    branch="$(git rev-parse --abbrev-ref HEAD)"

    if [[ "$new_branch" != "$branch" ]]; then
        printf "\\n${c_good}%s ${c_value}%s${c_reset}\\n" "Moving to new branch:" "$new_branch"

        # This will succeed but return error code 1 during a commit, hence the ||:
        git checkout -b "$new_branch" ||:

        # Only continue if we created and checked out the new branch
        [[ "$(git rev-parse --abbrev-ref HEAD)" == "$new_branch" ]]

        # Clean up old branch?
        printf  "${c_prompt}%s${c_reset}" "Delete old branch \"$branch\"? ([y]es/[n]o): "

        read -r response
        case $response in
            yes|y)  git branch -D "$branch" ;;
            *)      ;;
        esac
    fi
}
