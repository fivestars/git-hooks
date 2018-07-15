# Source this from your .bashrc or .bash_profile to enable tab-completion
# for the 'git hooks' command. This depends on your having already enabled
# general git completions.

__git_hooks_scripts () {
    # Populated in _verify_dirs
    local bare

    if bare=$(git rev-parse --is-bare-repository 2>/dev/null); then
        if $bare; then
            \ls "$(git rev-parse --git-dir)/.githooks" 2>/dev/null
        else
            \ls "$(git rev-parse --show-toplevel)/.githooks" 2>/dev/null
        fi
    fi
}

_git_hooks () {
    local subcommands="list enable disable run install uninstall install-command uninstall-command install-template uninstall-template include check-support parallel show-input config help"
    local subcommand
    local bash_source_dir
    local num_cores

    subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [[ -z "$subcommand" ]]; then
        __gitcomp "$subcommands"
        return
    fi

    local git_hook_names="applypatch-msg commit-msg fsmonitor-watchman post-applypatch post-checkout post-commit post-merge post-receive post-rewrite post-update pre-applypatch pre-auto-gc pre-commit pre-push pre-rebase pre-receive prepare-commit-msg push-to-checkout sendemail-validate update"

    case "$subcommand" in
    list)
        __gitcomp "$git_hook_names"
        ;;
    enable|disable)
        case "$cur" in
            --*) __gitcomp "--quiet" ;;
            *) __gitcomp "$git_hook_names $(__git_hooks_scripts)" ;;
        esac
        ;;
    run)
        case "$cur" in
            --*) __gitcomp "--force" ;;
            *) __gitcomp "$git_hook_names $(__git_hooks_scripts)" ;;
        esac
        ;;
    install)
        case "$cur" in
            --*) __gitcomp "--example --no-preserve" ;;
            *) ;;
        esac
        ;;
    install-alias|uninstall-alias)
        case "$cur" in
            --*) __gitcomp "--global --core" ;;
            *) ;;
        esac
        ;;
    install-template|uninstall-template)
        ;;
    include)
        bash_source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
        __gitcomp "$(\ls "$bash_source_dir/included")"
        ;;
    check-support)
        ;;
    parallel)
        if [ $cword -lt 4 ]; then
            __gitcomp "$git_hook_names"
        elif [ $cword -eq 4 ]; then
            num_cores=$(grep -c processor /proc/cpuinfo)
            __gitcomp "- $(seq 1 $num_cores) max"
        fi
        ;;
    show-input)
        if [ $cword -lt 4 ]; then
            __gitcomp "$git_hook_names"
        elif [ $cword -eq 4 ]; then
            __gitcomp "true false"
        fi
        ;;
    config)
        ;;
    help)
        case "$cur" in
            --*) __gitcomp "--markdown" ;;
            *) ;;
        esac
        ;;
    esac
}
