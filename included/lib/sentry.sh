#!/usr/bin/env bash

# shellcheck source=included/lib/core.sh
. "$1/core.sh" "$1"


function sentry_ensure_access () {
    # Ensures that all Sentry config values have been provided and that they allow access to the
    # Sentry api.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the required values
    # Stderr: An indication that the Sentry configuration values are not correct
    local invalid="${1:-false}" authorization org_uri

    sentry_ensure_configuration "$invalid"

    authorization="Authorization: Bearer $(git config --global sentry.api-token)"
    org_uri="https://sentry.io/api/0/organizations/$(git config --global sentry.organization)/"

    if curl -Ssf -H "$authorization" "$org_uri" &>/dev/null; then
        if "$invalid"; then
            printf "${c_good}%s${c_reset}\\n\\n" "Sentry configuration complete"
        fi
    else
        printf >&2 "\\n${c_error}%s${c_reset}\\n" "One or more of the Sentry configuration values were incorrect"
        sentry_ensure_access true
    fi
}

function sentry_ensure_configuration () {
    # Ensures that all Sentry configuration values exist in the global git config
    # If "invalid" is passed in as "true", this will prompt the user to enter
    # all these values anew (but the existing values will be displayed and accepted
    # if no new entry is provided)
    #
    # Return: 0
    # Stdout: Instructions on how to provide the required values
    # Stderr: <none>
    local response invalid="${1:-false}" hostname username api_token

    sentry_ensure_configuration_organization "$invalid"
    sentry_ensure_configuration_apitoken "$invalid"
}

function sentry_ensure_configuration_organization () {
    # Ensures that the sentry.organization value exists in the global git config
    # and prompts the user to enter it if it is not yet present.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the hostname
    # Stderr: <none>
    local response invalid=${1:-false} hostname

    if ! hostname=$(git config --global sentry.organization 2>/dev/null) || "$invalid"; then
        prompt_with_default_value "Enter the Sentry organization" "${hostname:-}"

        read -r response
        case "${response:-${hostname:-}}" in
            '') sentry_ensure_configuration_organization "$invalid" ;;
            *)  git config --global sentry.organization "${response:-${hostname:-}}" ;;
        esac
    fi
}

function sentry_ensure_configuration_apitoken () {
    # Ensures that the sentry.api-token value exists in the global git config and prompts the user
    # to enter it if it is not yet present.
    #
    # Return: 0
    # Stdout: Instructions on how to provide the api token
    # Stderr: <none>
    local response invalid=${1:-false} api_token

    if ! api_token="$(git config --global sentry.api-token 2>/dev/null)" || "$invalid"; then
        if [[ -z "${api_token:-}" ]]; then
            printf "    ${c_action}%s${c_reset}\\n" "Create a Sentry API token"
            open_uri "https://sentry.io/settings/account/api/auth-tokens/"
        fi

        prompt_with_default_value "Enter your Sentry api token" "${api_token:-}"

        read -r response
        case "${response:-${api_token:-}}" in
            '') sentry_ensure_configuration_apitoken "$invalid" ;;
            *)  git config --global sentry.api-token "${response:-${api_token:-}}" ;;
        esac
    fi
}

function sentry_get_issue_short_id {
    # Given a Sentry issue id (a numeric value that can be found in the issue's permalink URL),
    # returns the Sentry issue's human-readable short id (like SERVER-2C).
    #
    # Return: 0
    # Stdout: The issue's short id
    # Stderr: Instructions on how to provide Sentry API credentials, if not already present.
    local issue_id="$1" authorization issue_uri

    sentry_ensure_access >&2

    authorization="Authorization: Bearer $(git config --global sentry.api-token)"
    issue_uri="https://sentry.io/api/0/issues/${issue_id}/"
    curl 2>/dev/null -Ssf -H "$authorization" "$issue_uri" | jq -re '.shortId'
}

