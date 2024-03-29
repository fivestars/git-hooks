#!/usr/bin/env bash

# shellcheck source=included/lib/core.sh
. "$1/core.sh" "$1"

function jira_is_valid_branch_name () {
    jira_is_valid_ticket_branch_name "$1" || jira_is_valid_non_ticket_branch_name "$1"
}

function jira_is_valid_non_ticket_branch_name () {
    # Fail if the branch name does not match the expected pattern.
    # These branches would be used for scratch or sandbox work
    # that are not intended to be published as PRs.
    # The matching pattern starts with a magic string configured
    # by the git config value for 'git-hooks.non-ticketed-prefix'.
    # The default for this value is 'local-'.
    #
    # Examples of valid branch names:
    #    local-stuff
    #    local-stuff-2
    #    local-STUFF-234
    #    local-3
    #
    # Return: 0 or 1
    # Stdout: <none>
    # Stderr: <none>
    local non_ticketed_prefix
    non_ticketed_prefix="$(git config git-hooks.non-ticketed-prefix)" || non_ticketed_prefix="local"
    grep -qE "^${non_ticketed_prefix}(-[a-zA-Z0-9]+)+\$" <<<"$1"
}

function jira_is_valid_ticket_branch_name () {
    # Fail if the branch name does not match the expected pattern
    # Examples of valid branch names:
    #    JIRA-1
    #    JIRA-1234
    #    JIRA-1234-some-stuff
    #    myname-JIRA-1234
    #    myname-JIRA-1234-some-stuff
    #    myname2-JIRA-1234-some-stuff-v2
    #    2myname-JIRA-1234-some-stuff-v2
    #
    # Return: 0 or 1
    # Stdout: <none>
    # Stderr: <none>
    grep -qE '^([a-z0-9]+-)?[A-Z]+-[0-9]+(-[a-z0-9]+)*$' <<<"$1"
}

function jira_get_ticket_from_branch_name () {
    # Extract the JIRA-1243 portion of a well-formed branch name.
    #
    # Return: 0 or 1
    # Stdout: The Jira issue portion of the branch name, if present
    # Stderr: <none>
    local branch="$1"

    jira_is_valid_ticket_branch_name "$branch" && sed -E "s/^[^A-Z]*([A-Z]+-[0-9]+).*$/\\1/" <<<"$branch"
}

function jira_ensure_conforming_branch_name () {
    # Check if the provided branch name is well-formed, and if not, prompt the user to enter a new
    # one.
    #
    # Return: 0
    # Stdout: The well-formed branch name
    # Stderr: Instructions on how to provide the value
    local branch="$1"

    if ! jira_is_valid_branch_name "$branch"; then
        printf >&2 "${c_error}%s${c_reset}\\n\\n" "Invalid branch name"
        jira_ensure_conforming_branch_name "$(jira_get_new_branch_name)"
    else
        echo "$branch"
    fi
}

function jira_get_new_branch_name () {
    # Prompt the user to provide a conforming branch name.
    #
    # Return: 0
    # Stdout: The well-formed branch name
    # Stderr: Instructions on how to provide the value
    local branch jira_ticket response

    jira_ticket="$(jira_get_ticket)"

    if [[ "-" == "$jira_ticket" ]]; then
        branch="$(jira_get_new_non_ticketed_branch_name)"
    else
        branch="$(jira_get_username_prefix)-${jira_ticket}$(jira_get_suffix)"
    fi

    printf >&2 "${c_prompt}%s ${c_value}%s ${c_prompt}%s: ${c_reset}" "Branch" "$branch" "will be created unless you provide a new name now (optional)"

    read -r response
    case "$response" in
        '') ;;
        *)  branch="$response" ;;
    esac

    echo "$branch"
}

function jira_get_username_prefix () {
    # Provide the given author branch prefix value. If it is not yet present in the global git
    # config, prompt the user to enter it first.
    #
    # Return: 0
    # Stdout: The user-identifying string to be prepended to branch names
    # Stderr: Instructions on how to provide the value
    local response username prefix

    if ! git config jira.username-prefix 2>/dev/null; then
        jira_ensure_configuration_username >&2

        username=$(git config jira.username)
        prefix="${username%%.*}"

        printf >&2 "${c_prompt}%s (${c_value}%s${c_prompt}):${c_reset} " "Branch prefix name to use" "$prefix"

        read -r response
        case "$response" in
            '') ;;
            *)  prefix="$response" ;;
        esac
        git config --global jira.username-prefix "$prefix"

        echo "$prefix"
    fi
}

function jira_get_ticket () {
    # Prompt the user to provide the Jira ticket number. If the user indicates that the ticket does
    # not exist yet, send them to Jira to create it.
    #
    # Return: 0
    # Stdout: The JIRA-1234 formatted issue name
    # Stderr: Instructions on how to provide the value
    local response project project_id

    project=$(jira_ensure_project)
    project_id=$(git config -f .jira project."$project".id)

    printf >&2 "${c_prompt}%s${c_reset} %s\\n" "Provide your Jira issue number"
    printf >&2 "${c_prompt}%s${c_reset} %s\\n" " - leave blank if ticket doesn't exist yet"
    printf >&2 "${c_prompt}%s${c_reset} %s\\n" " - or use '-' to indicate a non-ticket branch"
    printf >&2 "${c_prompt}%s${c_reset} %s" ":" "${project}-"

    read -r response
    case "$response" in
        '') printf >&2 "    ${c_action}%s${c_reset}\\n" "Create a new ticket in Jira now"
            open_uri >&2 "https://$(git config jira.hostname)/secure/CreateIssue.jspa?pid=$project_id"
            jira_get_ticket
            ;;

        '-') echo '-'
            ;;

        *)  if grep -qE "^[0-9]+" <<<"$response"; then
                echo "${project}-${response}"
            else
                printf >&2 "${c_error}%s${c_reset}\\n" "Must be a numeric value"
                jira_get_ticket
            fi
            ;;
    esac
}

function jira_get_new_non_ticketed_branch_name () {
    local response non_ticketed_prefix branch

    non_ticketed_prefix="$(git config git-hooks.non-ticketed-prefix)" || non_ticketed_prefix="local"

    printf >&2 "${c_prompt}%s:${c_reset} %s-" "Provide a helpful suffix (optional)" "$non_ticketed_prefix"

    read -r response
    branch="${non_ticketed_prefix}-${response}"
    if jira_is_valid_non_ticket_branch_name "$branch"; then
        echo "${branch}"
    else
        printf >&2 "${c_error}%s${c_reset}\\n" "Must use alpha-numeric and hyphens(inclusively) only"
        jira_get_new_non_ticketed_branch_name
    fi
}

function jira_get_suffix () {
    # Prompt the user to provide an option branch name suffix to provide some hint as to its
    # purpose.
    #
    # Return: 0
    # Stdout: The hyphen-delimited suffix
    # Stderr: Instructions on how to provide the value
    local response

    printf >&2 "${c_prompt}%s:${c_reset} " "Provide a helpful suffix (optional)"

    read -r response
    if grep -qE '^$|^[a-z0-9]+(-[a-z0-9]+)*$' <<<"$response"; then
        echo "${response:+"-$response"}"
    else
        printf >&2 "${c_error}%s${c_reset}\\n" "Must use lowercase, alpha-numeric and hyphens(inclusively) only"
        jira_get_suffix
    fi
}

function jira_ensure_project () {
    # Ensures that the Jira project associated with the repository and its Jira id are present in
    # the .jira file. If they are not present, it will guide the user to enter them and then add the
    # .jira file to the git stage for commiting.
    #
    # Return: 0
    # Stdout: The Jira project key
    # Stderr: Instructions on how to provide the values for the .jira file
    local response project_key projects

    project_key=$(git config -f .jira project.key) ||:
    if [[ -z "$project_key" ]]  ; then
        jira_select_project
    else
        projects="$(git config -f .jira --get-regexp "project\\..*\\..*" | sed -E 's/project\.([A-Z]+).*/\1/')"
        if (( "$(echo "$projects" | wc -l)" > 1 )); then
            printf >&2 "${c_prompt}%s ${c_value}%s${c_prompt}%s${c_reset}" "Use current project" "${project_key}" "? ([y]es/[n]o):"
            read -r response
            case $response in
                yes|y|"")  echo "$project_key" ;;
                *)      jira_select_project "$projects" || jira_select_project ;;
            esac
        else
            git config -f .jira project.key "$project_key"
            git add .jira

            echo "$project_key"
        fi
    fi
}

function jira_select_project () {
    # Prompt the user to select a jira project. First from a list of projects found in .jira.
    # Then, if not provided there, let them choose from the complete list of projects in Jira.
    #
    # Return: 0
    # Stdout: The Jira project key
    # Stderr: Instructions on how to provide the values for the .jira file
    local required projects response

    if [[ -n "$*" ]]; then
        projects="$*"
        required=false
    else
        projects="$(jira_get_projects | jq 'keys[]')"
        required=true
    fi

    printf >&2 "${c_prompt}%s${c_reset}\\n%s\\n\\n" "Possible jira projects: " "$(xargs -n 5 <<<"${projects[@]}")"

    while [[ -z "${response:-}" ]]; do
        if "$required"; then
            printf >&2 "${c_prompt}%s${c_reset}" "Enter your Jira project key: "
        else
            printf >&2 "${c_prompt}%s${c_reset}" "Enter your Jira project key (leave blank to choose from a larger list): "
        fi

        read -r response
        if [[ -z "${response:-}" ]]; then
            if ! "$required"; then
                return 1
            fi
            printf >&2 "${c_error}%s${c_reset}\\n" "Must provide key"
            continue
        fi

        if ! grep -qE "^$(xargs <<<"${projects[@]}" | sed 's/ /\$|\^/g')$" <<<"$response"; then
            printf >&2 "${c_error}%s${c_reset}\\n" "Not a valid project key"
            response=
            continue
        fi
    done

    git config -f .jira project.key "$response"
    git config -f .jira project."$response".id "$(jira_get_projects | jira_get_jq_property "$response" | jira_get_jq_property id)"
    git add .jira

    echo "$response"
}

function jira_get_projects () {
    # Outputs the list of Jira project keys for all projects in Jira
    #
    # Return: 0 or 1
    # Stdout: A space-delimited list of project keys (all caps)
    # Stderr: <none>
    local projects

    jira_ensure_access >&2

    projects=$(curl -Ssf -u "$(git config jira.username):$(git config jira.api-token)" \
               "https://$(git config jira.hostname)/rest/api/2/project") || return 1
    jq -r 'reduce .[] as $item ({}; . + {($item.key): {id: $item.id, name: $item.name, uri:$item.self}} )' <<<"$projects"
}

function jira_get_issue {
    local issue_id="$1"

    jira_ensure_access >&2

    curl -Ssf -u "$(git config jira.username):$(git config jira.api-token)" \
        "https://$(git config jira.hostname)/rest/api/2/issue/$issue_id"
}

function jira_get_issue_url {
    local issue_id="$1"

    jira_ensure_access >&2

    echo "https://$(git config jira.hostname)/browse/${issue_id}"
}

function jira_get_jq_property () {
    # Receives a json body and outputs the JSON data for the given key
    #
    # Return: 0 or 1
    # Stdout: JSON data for the key, if present
    # Stderr: <none>
    jq -r --arg key "$1" '.[$key]'
}

function jira_ensure_access () {
    # Ensures that all Jira config values have been provided and that they allow access to the
    # Jira api.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the required values
    # Stderr: An indication that the Jira configuration values are not correct
    local invalid="${1:-false}" curl_user myself_uri

    jira_ensure_configuration "$invalid"

    curl_user="$(git config jira.username):$(git config jira.api-token)"
    myself_uri="https://$(git config jira.hostname)/rest/api/2/myself"

    if curl -Ssf -u "$curl_user" "$myself_uri" >/dev/null; then
        if "$invalid"; then
            printf "${c_good}%s${c_reset}\\n\\n" "Jira configuration complete"
        fi
    else
        printf >&2 "\\n${c_error}%s${c_reset}\\n" "One or more of the Jira configuration values were incorrect"
        jira_ensure_access true
    fi
}

function jira_ensure_configuration () {
    # Ensures that all Jira configuration values exist in the global git config
    # If "invalid" is passed in as "true", this will prompt the user to enter
    # all these values anew (but the existing values will be displayed and accepted
    # if no new entry is provided)
    #
    # Return: 0
    # Stdout: Instructions on how to provide the required values
    # Stderr: <none>
    local response invalid="${1:-false}" hostname username api_token

    jira_ensure_configuration_hostname "$invalid"
    jira_ensure_configuration_username "$invalid"
    jira_ensure_configuration_apitoken "$invalid"
}

function jira_ensure_configuration_hostname () {
    # Ensures that the jira.hostname value exists in the global git config and prompts the user
    # to enter it if it is not yet present.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the hostname
    # Stderr: <none>
    local response invalid=${1:-false} hostname

    if ! hostname=$(git config jira.hostname 2>/dev/null) || "$invalid"; then
        prompt_with_default_value "Enter the Jira hostname" "${hostname:-}"

        read -r response
        case "${response:-${hostname:-}}" in
            '') jira_ensure_configuration_hostname "$invalid" ;;
            *)  git config --global jira.hostname "${response:-${hostname:-}}" ;;
        esac
    fi
}

function jira_ensure_configuration_username () {
    # Ensures that the jira.username value exists in the global git config and prompts the user
    # to enter it if it is not yet present.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the username
    # Stderr: <none>
    local response invalid=${1:-false} username

    if ! username="$(git config jira.username 2>/dev/null)" || "$invalid"; then
        prompt_with_default_value "Enter your Jira email address" "${username:-}"

        read -r response
        case "${response:-${username:-}}" in
            '') jira_ensure_configuration_username "$invalid" ;;
            *)  git config --global jira.username "${response:-${username:-}}" ;;
        esac
    fi
}

function jira_ensure_configuration_apitoken () {
    # Ensures that the jira.api-token value exists in the global git config and prompts the user
    # to enter it if it is not yet present.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the api token
    # Stderr: <none>
    local response invalid=${1:-false} api_token

    if ! api_token="$(git config jira.api-token 2>/dev/null)" || "$invalid"; then
        if [[ -z "${api_token:-}" ]]; then
            printf "    ${c_action}%s${c_reset}\\n" "Create a Jira API token"
            open_uri "https://id.atlassian.com/manage-profile/security/api-tokens"
        fi

        prompt_with_default_value "Enter your Jira api token" "${api_token:-}"

        read -r response
        case "${response:-${api_token:-}}" in
            '') jira_ensure_configuration_apitoken "$invalid" ;;
            *)  git config --global jira.api-token "${response:-${api_token:-}}" ;;
        esac
    fi
}
