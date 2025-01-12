<p align="center">
  <!-- <img src="_github_assets/logo.svg" /> -->
  <img src="_github_assets/logo_light.png" alt="Logo" />
</p>

----------

[![CI](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml/badge.svg)](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/Version-1.0.0_beta.1-brightgreen.svg)
[![Version](https://img.shields.io/badge/Supported_shells-Zsh,_Bash-brightgreen.svg)](#supported-shells)

## Define folder specific aliases, functions and variables in your shell

Sherpa is a shell extension that allows you to define new or override existing variables, aliases and functions on a per-folder basis, with support for nesting.

It's similar to [Direnv](https://github.com/direnv/direnv), but with fewer features and added support for aliases and functions.

## Video Demo

## ASCII Demo

```shell
$ cd ~/projects

$ echo "$VAR_1"
GLOBAL VAR
$ alias_1
GLOBAL ALIAS
$ function_1
GLOBAL FUNCTION

$ cd project_awesome

$ echo "$VAR_1"
LOCAL VAR PROJECT AWESOME
$ alias_1
LOCAL ALIAS PROJECT AWESOME
$ function_1
LOCAL FUNCTION PROJECT AWESOME

$ cd ..

$ echo "$VAR_1"
GLOBAL VAR
$ alias_1
GLOBAL ALIAS
$ function_1
GLOBAL FUNCTION
```

The above is accomplished with the help of Sherpa and the files below.

```shell
# ~/.bashrc or ~/.zshrc etc...
export VAR_1="GLOBAL VAR"

alias alias_1='echo "GLOBAL ALIAS"'

function_1() {
  echo "GLOBAL FUNCTION"
}
```

```shell
# ~/projects/project_awesome/.envrc
export VAR_1="LOCAL VAR PROJECT AWESOME"

alias alias_1='echo "LOCAL ALIAS PROJECT AWESOME"'

function_1() {
  echo "LOCAL FUNCTION PROJECT AWESOME"
}
```

## Basic usage

1. $ cd ~/projects/project_awesome
2. $ sherpa edit
    1. Sherpa opens the env file in your editor
    2. You update, save then close it
    3. Sherpa unloads the previous version, trusts and loads the current one automatically
3. You can nest envs by repeating this in subdirectories
4. [Disco](https://www.youtube.com/watch?v=UkSPUDpe0U8)

For more details see the [Features](#features) section.

## Supported shells

- Zsh (5.3.1 or higher)
- Bash (4.3 or higher)

## Tested on

- macOS 13 - Ventura
- macOS 14 - Sonoma
- macOS 15 - Sequoia
- Ubuntu 20.04
- Ubuntu 22.04

## Supported Shell entities for unloading

- Exported variables
- Aliases
- Functions

Experimental feature: Non-exported variables and dynamically created entities
are supported by setting the `SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING`
environment variable to `true`. This executes the env file in a subshell
three times when cd'ing into a directory.

## Good to know

When sherpa loads the env, it sources the env file meaning its whole content
is executed in the current shell.

## Installation

```shell
# Clone the repo
$ git clone git@github.com:tothpeter/local_sherpa.git ~/.dotfiles/lib/local_sherpa

# Hook it into your shell
## Zsh
$ echo "source ~/.dotfiles/lib/local_sherpa/init.sh" >> ~/.zshrc
## Bash
$ echo "source ~/.dotfiles/lib/local_sherpa/init.sh" >> ~/.bashrc

# Exclude the env files (.envrc) globally in Git
$ echo ".envrc" >> $(git config --global core.excludesfile)

# Reload or restart your shell

# Optional but recommended
alias se='sherpa edit'
alias st='sherpa trust'
alias upgrade_sherpa='git -C ~/.dotfiles/lib/local_sherpa pull'
```

## Features

See the full list of commands by running `$ sherpa` in your shell.

### Security

Sherpa won't load any env file unless you trust them first.\
This is to prevent running malicious code when you `cd` into a directory.

``` bash
$ echo "alias rs=rspec" > ~/projects/project_awesome/.envrc
$ cd ~/projects/project_awesome
Sherpa: The env file is not trusted. Run `sherpa trust` to mark it as trusted.
$ rs
command not found: rs
$ sherpa trust
Sherpa: Trusted!
$ rs
# rspec starts
```

When an env file changes you have to trust it again.

Use `sherpa edit`. It opens the env file in your default editor then trusts it
automatically when you close it.

You can untrust a directory with `sherpa untrust`.

### Loading envs from parent directories automatically

It is not supported currently. Feel free to open a feature request.

### Env loading and unloading

- Sherpa supports nested envs
  - It unloads the envs in the correct order when leaving a directory to restore
    the overridden items.
  - Subfolders can override the items defined in the parent folders.
- Sherpa does not unload the loaded envs when you `cd` into a subdirectory.
- Experimental feature: Non exported variables and dynamically created entities
  are unloaded only if the `SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING` environment
  variable is set to `true`.

#### Demo

```shell
# Given the following directory structure with the corresponding env files
# ~/projects/.envrc
# ~/projects/project_awesome/.envrc
# ~/projects/project_awesome/subdir

$ cd ~/projects/
# Sherpa loads the env for projects
# Items defined in this folder override the items defined in the global env
$ cd project_awesome
# Sherpa does not unload the previous env
# Sherpa loads the env for project_awesome
# Items defined in this folder override the items defined in previous envs
$ cd subdir
# Sherpa does not unload the previous envs
$ cd ..
# Sherpa does not reload the env for project_awesome
$ cd ..
# Sherpa unloads the env for project_awesome and restores the env for projects
# This rolls back the overrides made by the env of project_awesome
$ cd ..
# Sherpa unloads the env for projects and restores the global env
# This rolls back the overrides made by the env of projects
```

### Aliases and functions in the env file taking precedence

Declaring a function in the env file with the same name as an existing alias
will override the alias automatically. No need to call `unalias`.\
The same applies to declaring aliases in the env
file with the same name as existing functions.

### Running a script when leaving a directory

It is not supported currently. Feel free to open a feature request.\
Alternatively, you can use: https://github.com/hyperupcall/autoenv

## Configuration

Set the following environment variable anywhere to instruct Sherpa on how
to operate.

```shell
export SHERPA_ENV_FILENAME='.env' # Default: .envrc
# To support unloading non-exported variables and dynamically created Shell entities
export SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING=true
# To auto dump the env into a .envrc.example file when running `sherpa edit`
export SHERPA_DUMP_ENV_ON_EDIT=true
```

## Settings

### Log level

It affects only the current and new terminal sessions.

```shell
$ sherpa talk more   # - Decrease the log level | Alias: -
$ sherpa talk less   # - Increase the log level | Alias: +
$ sherpa debug       # - Debug level            | Alias: dd
$ sherpa shh         # - Silence
$ sherpa log         # - Open the log options menu | Alias: talk
$ sherpa log [LEVEL] # - Set a specific log level  | Levels: debug, info, warn, error, silent | Alias: talk
```

### Disable/enable Sherpa

It affects only the current and new terminal sessions.

```shell
$ sherpa off # aliases: sleep, disable
Sherpa: All envs are unloaded. Sherpa goes to sleep.
$ sherpa on # aliases: work, enable
Sherpa: Env is loaded. Sherpa is ready for action.
```

## Cookbook

### Run RSpec in a container or else

```shell
# Run RSpec in the `project-awesome-api` Docker container

# ~/projects/project_awesome_api/.envrc
alias de='docker exec -it project-awesome-api'
alias rs='de rspec'
```

```shell
# Run RSpec on the host machine

# ~/projects/project_for_mortals/.envrc
alias rs='bin/rspec'
```

With this config `RSpec` will run depending on in which directory you `cd` into.

### Run the tests using the same shortcut in different projects

```shell
# ~/projects/project_ruby_with_docker/.envrc
alias t='docker exec -it project-awesome-api rspec'

# ~/projects/project_elixir/.envrc
alias t='mix test'

# ~/projects/project_js_with_jest/.envrc
alias t='yarn test'
```

### Rails console in production 🤫

```shell
# ~/projects/project_with_heroku/.envrc
alias rc_prod='heroku run rails c -a APP_NAME'

# ~/projects/project_with_aws/.envrc
alias rc_prod='ssh -i /path/key-pair-name.pem user@hostname "/var/app/current/bin/rails console"'
```

### Start your dev environment

```shell
# ~/projects/project_with_docker/.envrc
alias up='docker-compose up -d'
alias upb='docker-compose up --build -d'
alias down='docker-compose down'

# ~/projects/project_basic/.envrc
alias up='bin/rails s'
```

## Troubleshooting

```shell
$ sherpa diagnose
$ sherpa status
```

## Local development

### Testing

All *_test.sh files are run recursively from the tests directory.

```shell
# Run all the tests for all the supported shells
$ make test

# Run a single test for all the supported shells
$ make test tests/features/edit_test.sh

# Run all the tests from a folder for all the supported shells
$ make test tests/features

# Run all the tests for Zsh
$ make test_zs

# Run a single test for Zsh
$ make test_zs tests/features/edit_test.sh

# Run all the tests from a folder for Zsh
$ make test_zs tests/features

# Run all the tests for Bash
$ make test_bash

# Run a single test for Bash
$ make test_bash tests/features/edit_test.sh

# Run all the tests from a folder for Bash
$ make test_bash tests/features

# Run all the tests for all the supported shells in Ubuntu
$ make test_all_in_ubuntu

# Run a single test for all the supported shells in Ubuntu
$ make test_all_in_ubuntu tests/features/edit_test.sh

# Test the performance for all the supported shells
# It is not a real test, it is more like a benchmark
$ make test_performance
```

### Linting

```shell
$ make lint
```

## Credits

The core functionality (var, func and alias stashing) of this project was inspired by [Varstash](https://github.com/cxreg/smartcd?tab=readme-ov-file#varstash).

Special thanks to its author:
- Dave Olszewski <cxreg@pobox.com>
