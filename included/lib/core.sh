#!/usr/bin/env bash

# shellcheck source=included/lib/colors.sh
. "$1/colors.sh" "$1"

# Themed colors - export these in your shell to override
c_good="${c_good:-${green}}"
c_warning="${c_warning:-${b_red}}"
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
    protected="^${protected// /\$|^}\$"

    grep -qE "$protected" <<<"$1"
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

    branch="$(git symbolic-ref --short HEAD)"

    if [[ "$new_branch" != "$branch" ]]; then
        printf "\\n${c_action}%s ${c_value}%s${c_reset}\\n" "Moving to new branch:" "$new_branch"

        # This will succeed but return error code 1 during a commit, hence the ||:
        git checkout -b "$new_branch" | grep -v "Switched to a new branch" ||:

        # Only continue if we created and checked out the new branch
        [[ "$(git symbolic-ref --short HEAD)" == "$new_branch" ]]

        # Clean up old branch?
        if ! is_protected_branch "$branch"; then
            printf  "${c_prompt}%s${c_reset}" "Delete old branch \"$branch\"? ([y]es/[n]o): "

            read -r response
            case $response in
                yes|y)  git branch -D "$branch" ;;
                *)      ;;
            esac
        fi
    fi
}

function get_cached_commit_message_filename {
    local commit="${1:-HEAD}"
    local repo="$(basename "$(git rev-parse --show-toplevel)")"
    local branch="$(git rev-parse --abbrev-ref "$commit" 2>/dev/null)"
    local hash="$(git rev-parse --short "$commit" 2>/dev/null)"

    echo "/tmp/git-commit-msg-${repo}-${branch}-${hash}"
}

function clear_cached_commit_message_in_use {
    rm -f .git/CACHED_COMMIT_MSG
}

function set_cached_commit_message_in_use {
    cp "$1" .git/CACHED_COMMIT_MSG
    mv "$1" "$2"
}

function is_cached_commit_message_in_use {
    [[ -f .git/CACHED_COMMIT_MSG ]]
}
