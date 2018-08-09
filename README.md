# git-hooks
A tool for managing and invoking custom git hook scripts.

## Description:

git-hooks is a tool to facilitate git hook management, specifically being
able to store your hooks under source control within the repository itself
and simply reference them from a multiplexer hook installed in the
`.git/hooks` directory.

The expected usage is to write an arbitrary number of individual hook
scripts associated with a single standard git hook and store them in the
`.githooks` directory. When git invokes the multiplexer script in `.git/hooks`,
it will call your custom scripts sequentially, or in parallel if you
configure it to do so.

This way you can break your monolithic hooks into individual files, giving
you greater flexibility regarding which pieces to run and when.

## Installation:

#### Install GNU getopt (if not already present for your platform).
```

    getopt -T
    if [[ $? -ne 4 ]]; then
        brew install gnu-getopt
        # -- or --
        sudo port install getopt
    fi

```

#### Install `git hooks` as a git global alias (optional)

This allows you to do `git hooks install` in new repositories rather than
locating the command via its path. Regardless, a local alias will be created
in your repository's git config in the next step.

See the `git hooks install-template` instructions below for the recommended
way of ensuring all of your future cloned and created repositories automatically
get `git hooks` support right out of the box.
```
    path/to/git-hooks/git-hooks install-command --global
```

#### Install the multiplexers and the 'git hooks' alias in a repository
```

    cd <to your repo>
    git hooks install
    # -- or, if you skipped the global git alias step above ---
    path/to/git-hooks/git-hooks install

```

#### Configure git to automatically install the multiplexers for all new repos (cloned or init'ed)

This will make it so that you never have to run `git hooks install` again for this machine.
This is useful when your repositories already have a `.githooks` directory with hook
scripts in it or if you plan to make regular use of the `git hooks` functionality in other
or future repositonies.
```

    git hooks install-template
    # -- or, if you skipped the global git alias step above ---
    path/to/git-hooks/git-hooks install-template

```

## Usage:
        git hooks  # equivalent to list
    or: git hooks list [<git hook>...]
    or: git hooks enable [-q|--quiet] <git hook>... <custom script name>...
    or: git hooks disable [-q|--quiet] <git hook>... <custom script name>...
    or: git hooks run [-f|--force] <git hook>|<custom script name>
    or: git hooks install [--no-preserve] [--no-alias]
    or: git hooks uninstall 
    or: git hooks install-command [--local] [--global] [--core]
    or: git hooks uninstall-command [--local] [--global] [--core]
    or: git hooks install-template 
    or: git hooks uninstall-template 
    or: git hooks include [<custom script name>...]
    or: git hooks check-support 
    or: git hooks parallel <git hook> [<num>]
    or: git hooks show-input <git hook> [true|false]
    or: git hooks config 
    or: git hooks help [--markdown]

## Files:
    .githooks/
        This is where git-hooks will look for default hook scripts. Place your
        hook scripts in here rather than .git/hooks. Your hook scripts should
        be executable and follow the naming convention:

            <standard git hook name>-<custom suffix>[.<file extension>]

        They will be executed in alphabetical order, so if you wish to control
        the order of execution, take that into account when naming the files.

        Examples: .githooks/pre-commit-00-style.sh
                  .githooks/pre-commit-01-unittest.py

    .git/config
        git-hooks config settings will be stored in your repository's config
        file. In the case of a bare repository, the config file is located at
        ./config.

    ~/.gitconfig
        If you opt to install the 'git hooks' alias as a global alias, it will
        be added to this file.

    ~/.gittemplate/hooks
    ~/.gittemplate/config
        These files will be updated if you choose to install the hooks into your
        repository template by running 'git hooks install-template'.

## Common Arguments:
    <path>...
        The command accepts a list of path strings.

    <git hook>...
        The command accepts a list of git hook names. These names should only
        include the names of the standard git hooks:

            applypatch-msg
            commit-msg
            fsmonitor-watchman
            post-applypatch
            post-checkout
            post-commit
            post-merge
            post-receive
            post-rewrite
            post-update
            pre-applypatch
            pre-auto-gc
            pre-commit
            pre-push
            pre-rebase
            pre-receive
            prepare-commit-msg
            push-to-checkout
            sendemail-validate
            update

    <custom script name>...
        The command accepts a list of hook script names. These names must
        indicate scripts in the repo's .githooks directory. Standard git hook
        names are not considered valid items in this list.

## Operations:

    list [<git hook>...]
        Lists the currently available custom scripts for each standard git
        hook. If any are disabled, it is noted in the output.

    enable [-q|--quiet] <git hook>... <custom script name>...
        Enables a script (or scripts) to be run during git hook
        invocation. Scripts are enabled by default.
    
        If --quiet is specified, the updated enabled state of all hook
        scripts will not be displayed.

    disable [-q|--quiet] <git hook>... <custom script name>...
        Prevents a script from being run during git hook invocation.
    
        If --quiet is specified, the updated enabled state of all hook
        scripts will not be displayed.

    run [-f|--force] <git hook>|<custom script name>
        Runs a git hook or an individual custom script. stdin and any
        extra arguments will be forwarded to the designated target.
    
        This command respects the enabled/disabled state of the hooks and
        scripts. You can force the hook or script to run by specifying the
        --force flag.

    install [--no-preserve] [--no-alias]
        Installs the multiplexer hooks into the .git/hooks directory.
        These scripts are the core of the git-hooks functionality.
        They are responsible for running any configured custom scripts
        according to your specifications (sequential vs parallel,
        disabled, etc.). This operation alse creates the .githooks
        directory and moves any existing hooks into it. Any scripts
        moved in this process will receive the "-moved" suffix.
    
        It will also create the git alias 'git hooks' in the local
        repo's config if the global alias is not already present.
    
        If --no-preserve is specified, no existing hook scripts in
        .git/hooks will be moved to the .githooks directory with the
        "-moved" suffix.
    
        If --no-alias is specified, the local 'git hooks' alias will
        not be created.

    uninstall 
        Removes the multiplexer hooks from the .git/hooks directory and
        removes the 'hooks' alias from the repo's config, if present.

    install-command [--local] [--global] [--core]
        Installs 'git-hooks' alias into any of three locations.
            --local: add it to the current repository's git aliases
            --global: add it to the global git aliases
            --core: Links this file into this machine's git core
                    directory. Any 'hooks' aliases will no longer be
                    effective.
    
        If neither --local nor --core are specified, the alias will be
        installed into the global git config.

    uninstall-command [--local] [--global] [--core]
        Clears the 'git-hooks' alias from the specified location.
            --local: Remove it from the repository's aliases
            --global: Remove it from the global aliases
            --core: Delete the git-hooks link from this machine's git
                    core directory.
    
        If neither --local nor --core are specified, the alias will be
        removed from the global git config.

    install-template 
        Installs the multiplexer scripts into ~/.gittemplate/hooks (or
        into the location defined by the init.templatedir config value).
        This will cause any subsequently cloned or created repositories to
        automatically populate their .git/hooks directories with the
        multiplexer script and provide them with the 'git hooks' alias.
    
        To update previously cloned repositories, just run 'git init' again.

    uninstall-template 
        Undoes the effects of 'install-template'.

    include [<custom script name>...]
        Copies a script included with the git-hooks command to your
        repository's .githooks directory.
    
        If run with no arguments, a list of available scripts and their
        purposes will be displayed.

    check-support 
        Checks for differences in the list of hooks supported by
        git-hooks and the list of hooks supported by git. If differences
        are present, consider upgrading git-hooks or git.

    parallel <git hook> [<num>]
        Modify the hooks.<git hook>.parallel config setting. <num> should
        be the desired number of jobs to spawn when running the hook
        scripts. If the second argument is not provided, it will display
        the current setting. If <num> is 'max', it will be interpreted as
        the number of CPUs as seen by cpuid. If <num> is "-", the current
        setting will be cleared and the hook will not be run in parallel
        mode.
    
        When running in parallel, each script's output is buffered until
        it finishes. When complete, the output will be written to stdout.

    show-input <git hook> [true|false]
        Modify the hooks.<git hook>.showinput config setting. If no value
        is provided, it will display the current setting. If this setting
        is true, the received arguments and stdin will be displayed during
        git hook invocation.

    config 
        Simply lists all hooks-related git config settings.

    help [--markdown]
        Displays this help message.
    
        If --markdown is specified, the help message will be generated with
        additional markdown syntax for headings and code blocks.

## Writing custom git hook scripts:

Once `git-hooks install` has been called for your repository, creating and
installing your own hooks is a simple matter of placing them in the newly-
created `.githooks` directory. Your hooks must follow a particular naming
convention:

```
       <standard git hook name>-<custom suffix>
```

When a git hook is invoked it will look for your hooks scripts with the
corresponding prefix and call them according to your config. By default
your scripts will be run sequentially in alphabetical order as they appear
in the `.githooks` directory.

Setting the parallel option (see above) will cause all scripts to be run
concurrently without regard to their conventional order.

###    Preventing parallel execution:

If your script cannot be run in parallel with another of the same
git hook family, you may enforce this by calling the exported function
`prevent-parallel` from within your script.

Example:
```

        #!/usr/bin/env bash
        prevent-parallel   # Will exit the hook with a non-zero exit code
                           # unless it is being run sequentially.

```
