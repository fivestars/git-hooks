# git-hooks
A tool for managing and invoking custom git hook scripts.

## Description:
 **git-hooks** is a tool to facilitate git hook management, specifically being able to store your hooks under source control within the repository itself and simply reference them from a multiplexer hook installed in the `.git/hooks` directory.  

 The expected usage is to write an arbitrary number of individual hook scripts associated with a single standard git hook and store them in the `.githooks` directory. When git invokes the multiplexer script in `.git/hooks`, it will call your custom scripts sequentially, or in parallel if you configure it to do so.  

 This way you can break your monolithic hooks into individual files, giving you greater flexibility regarding which pieces to run and when.  

## Features:

### Run your hooks directly:
 **git-hooks** allows you to invoke your hook scripts without being triggered by a git action. This is useful for speeding up the process of debugging issues that caused your hooks to fail in the first place. If you write your hook scripts well, you can even pass extra arguments to your scripts that wouldn't be present when being run from a git trigger. (eg. specifying a particular unit test to speed up debugging).  

### Disable/enable particular hooks or hook scripts:
 **git-hooks** gives you the ability to disable hooks down to the individual script level. So if something is preventing a particular script from succeeding and can be temporarily ignored, you can just disable that one and the other scripts for that trigger will still apply. This is much better than `--no-verify`.  

### Hook repositories:
 Rather than copying and pasting the same hook code into each of your repositories, you can create a shared collection of hooks (as a git repo) and simply reference those from within your repository. This way, as your hook functionality evolves, you only need to push the code to the collection's repo, and **git-hooks** will ensure that you pull down the latest.  

### Global hooks:
 You can have global hooks on your machine. These will be run for any repository that has **git-hooks** installed (ie. has the multiplexer scripts in its `.git/hooks` dir. See **Installation** below). This is useful for applying consistent, project-agnostic rules across all of your projects (such as commit message format/structure). These hooks can be literal script files or reference hooks, but they will not be checked into the source control of the repositories that they will affect. They will appear and run alongside the repo's own hooks.  

 Global hooks will be enabled by default for all repos with **git-hooks** installed. If you wish to prevent the global git hooks from running for a repostiory, set the local git config value of `git-hooks.global-enabled` to `false` within the repository. This will allow you to continue to use the repo's source-controlled git hooks.  

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

#### Install `git hooks` 
 This will symlink `git-hooks` to `/usr/local/bin`. This allows `git` to treat it as a first-class command. In other words, you can invoke its behavior via `git hooks ...`.  
```
    path/to/git-hooks/git-hooks install-command

```

#### Install the multiplexers for all new repos (cloned or init'ed) 
 This will make it so that you never have to run `git hooks install` again for this machine. This is useful when your repositories already have a `.githooks` directory with hook scripts in it or if you plan to make regular use of the `git hooks` functionality in other or future repositonies. Be sure to run `git hooks install` in any repositories that existed prior to installing the template configuration, as they will still need to be setup with the multiplexer scripts.  
```
    git hooks install-template

```

#### Manually install the multiplexers into a repository 
 If you choose to not use the template configuration, you can still install `git-hooks` support manually on a per-repostory basis.  
```
    cd <to your repo>
    git hooks install

```

## Usage:
        git hooks  # equivalent to list
    or: git hooks list [<git hook>...]
    or: git hooks enable [-q|--quiet] <git hook>... <custom script name>...
    or: git hooks disable [-q|--quiet] <git hook>... <custom script name>...
    or: git hooks run [-f|--force] <git hook>|<custom script name>
    or: git hooks install [--no-preserve]
    or: git hooks uninstall 
    or: git hooks install-command 
    or: git hooks uninstall-command 
    or: git hooks install-template 
    or: git hooks uninstall-template 
    or: git hooks add-collection [-g|--global] <collection name> <clone url> [<subpath to hooks>]
    or: git hooks list-collections [-g|--global]
    or: git hooks sync-collection [-g|--global] <collection name>
    or: git hooks include [-g|--global] <collection name> <git hook> <hook executable> [<new name>]
    or: git hooks check-support 
    or: git hooks parallel <git hook> [<num>]
    or: git hooks show-input <git hook> [true|false]
    or: git hooks config 
    or: git hooks help [-m|--markdown]

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
        Some configs, such as unicode output and color output support will be stored here.
        Additionally, the periodic update check information is stored here.

    ~/.gittemplate/hooks
    ~/.gittemplate/info/exclude
        These files will be updated if you choose to install the hooks into your
        repository template by running 'git hooks install-template'.

## Configuration:
    Set these git config values (recommended that you use --global) to modify git-hooks behavior.

    git-hooks.unicode [default=true]
        Use unicode glyphs in certain operations' output (eg. git-hooks list)
        If false, standard ascii characters will be used instead

    git-hooks.color [default=true]
        Use colorized output.

## Operations:

    list [<git hook>...]
        List all hooks for the current repository and their runnable state.

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

    install [--no-preserve]
        Installs the multiplexer hooks into the .git/hooks directory.
        These scripts are the core of the git-hooks functionality.
        They are responsible for running any configured custom scripts
        according to your specifications (sequential vs parallel,
        disabled, etc.). This operation alse creates the .githooks
        directory and moves any existing hooks into it. Any scripts
        moved in this process will receive the "-moved" suffix.
    
        If --no-preserve is specified, no existing hook scripts in
        .git/hooks will be moved to the .githooks directory with the
        "-moved" suffix.

    uninstall 
        Removes the multiplexer hooks from the .git/hooks directory.

    install-command 
        Creates a symlink to git-hooks in /usr/local/bin

    uninstall-command 
        Removes the symlink to git-hooks in /usr/local/bin, if present.

    install-template 
        Installs the multiplexer scripts into ~/.gittemplate/hooks (or
        into the location defined by the init.templateDir config value).
        This will cause any subsequently cloned or created repositories to
        automatically populate their .git/hooks directories with the
        multiplexer script.
    
        To update previously cloned repositories, just run 'git init' again.

    uninstall-template 
        Undoes the effects of 'install-template'.

    add-collection [-g|--global] <collection name> <clone url> [<subpath to hooks>]
        Configures this repository to be able to reference git hooks hosted
        in a remote locatior (currently only supports git repositories).
    
        [-g|--global]:      The collection will be considered available to all repos.
        <collection name>:  The internal name for the collection. Must be unique
                            within this repository or if global, within all global
                            collections.
    
        <clone url>:        The collection's remote url.
    
        <subpath to hooks>: The collection-relative path to the hook directories.

    list-collections [-g|--global]
        List the collections configured for the indicated scope.
    
        [-g|--global]:      List collections configured at the global scope. If not
                            specified, this will list collections configured for
                            the current repository.

    sync-collection [-g|--global] <collection name>
        Pull the latest updates for the indicated collection. This will happen
        automatically periodically, but this command is for situations where
        you don't want to wait for that automatic update to occur.
    
        [-g|--global]:      The collection will be considered available to all repos.
        <collection name>:  The internal name for the collection to be updated.

    include [-g|--global] <collection name> <git hook> <hook executable> [<new name>]
        Link an existing script from a collection into this repository.
        If <new name> is provided, that name will be used instead of <hook script>
        for the reference file installed into the repository. This is useful when one
        wishes to specify a strict order to in which to run multiple scripts for
        <git hook>. Just provide a numeric prefix on the <new name> to indicate
        the script's place in the running order.
    
            Specify '--global' if you want to reference a hook in a global collection.
            Using this, it's possible to take advantage of project-agnostic hooks without
            even placing them (or references to them) under your project's source control.
            Bear in mind that some hooks will place files under the project's source
            control as a side-effect of their behavior. This is to be expected.

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

    help [-m|--markdown]
        Displays this help message.
    
        If --markdown is specified, the help message will be generated with
        additional markdown syntax for headings and code blocks.

## Writing custom git hook scripts:
 Creating and installing your own hooks is a simple matter of placing them in your repository's `.githooks` directory. If you only have one or two hook scripts, you can use the `<standard git hook name>-<custom suffix>` naming convention. If you desire a little more organizational structure, you can create subdirectories in the `.githooks` directory corresponding to the standard git hook names and place your scripts within those. For example:  
```
    <your repo>/
        .githooks/
            commit-msg/
                format-check
            pre-commit/
                style-check
                unit-tests

```
 When a git hook is invoked it will look for your hooks scripts with the corresponding prefix and call them according to your config. By default your scripts will be run sequentially in alphabetical order as they appear in the `.githooks` directory.  Setting the parallel option (see above) will cause all scripts to be run concurrently without regard to their conventional order.  

###    Preventing parallel execution:
 If your script cannot be run in parallel with another of the same git hook family, you may enforce this by calling the exported function `prevent-parallel` from within your script.  Example:  
```
        #!/usr/bin/env bash
        prevent-parallel   # Will exit the hook with a non-zero exit code
                           # unless it is being run sequentially.

```
