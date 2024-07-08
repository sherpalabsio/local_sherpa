# Local Sherpa to the Rescue

Sherpa carries your local environment settings for you as you `cd` around your projects.

## Status

Unstable, under heavy development.

[![example workflow](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml/badge.svg)](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml)

## Demo

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

The above is accomplished with the help of Local Sherpa and the files below.

```shell
# ~/.bash_profile or ~/.bashrc or ~/.zshrc etc...
export VAR_1="GLOBAL VAR"

alias alias_1='echo "GLOBAL ALIAS"'

function_1() {
  echo "GLOBAL FUNCTION"
}
```

```shell
# ~/projects/project_awesome/.local-sherpa
export VAR_1="LOCAL VAR PROJECT AWESOME"

alias alias_1='echo "LOCAL ALIAS PROJECT AWESOME"'

function_1() {
  echo "LOCAL FUNCTION PROJECT AWESOME"
}
```

## Usage
### Setup / config local env
1. $ cd ~/projects/project_awesome
2. $ sherpa edit
3. [Disco](https://www.youtube.com/watch?v=UkSPUDpe0U8)

For more details see the [Features](#features) section.

### Security

Sherpa won't load any local env file unless you trust the directory first.
This is to prevent running malicious code when you `cd` into a directory.

``` bash
$ echo "alias rs=rspec" > ~/projects/project_awesome/.local-sherpa
$ cd ~/projects/project_awesome
Sherpa: The local env file is not trusted. Run `sherpa trust` to mark it as trusted.
$ rs
command not found: rs
$ sherpa trust
Sherpa: Trusted!
$ rs
# rspec starts
```

When a local env file changes you have to trust the directory again.

Use `sherpa edit`. It opens the local env file in your editor then trusts it
automatically when you close the file.

You can untrust a directory with `sherpa untrust`.

## Supported shells

- Zsh
- Bash

## Tested on

- macOS 12 - Monterey
- macOS 13 - Ventura
- macOS 14 - Sonoma
- Ubuntu 20.04
- Ubuntu 22.04

## Supported data structures and things

- Exported variables
- Aliases
- Functions

Unexported variables and other data types are not supported yet.

## Installation

```shell
# Clone the repo
$ git clone git@github.com:tothpeter/local_sherpa.git ~/.dotfiles/lib/local_sherpa
# Hook it into your shell
$ echo "source ~/.dotfiles/lib/local_sherpa/local_sherpa.sh" >> ~/.zshrc
# Exclude the local env Sherpa files (.local-sherpa) globally in Git
$ echo ".local-sherpa" >> $(git config --global core.excludesfile)

# Optional but recommended
alias se='sherpa edit'
alias st='sherpa trust'
alias upgrade_sherpa='git -C ~/.dotfiles/lib/local_sherpa pull'
```

## Features

See the full list of commands by running `$ sherpa` in your shell.

### Loading local env from parent directories automatically

It is not supported currently. Feel free to open a feature request issue
if you find it useful.

### Flexible and nested loading and unloading of local envs

```shell
# Given the following directory structure with the corresponding local env files
# ~/projects/.local-sherpa
# ~/projects/project_awesome/.local-sherpa
# ~/projects/project_awesome/subdir

$ cd ~/projects/
# Sherpa loads the local env for projects
# Items defined in this folder override the items defined in the global env
$ cd project_awesome
# Sherpa does not unload the previous local env
# Sherpa loads the local env for project_awesome
# Items defined in this folder override the items defined in previous envs
$ cd subdir
# Sherpa does not unload the previous local envs
$ cd ..
# Sherpa does not reload the local env for project_awesome
$ cd ..
# Sherpa unloads the local env for project_awesome and restores the local env for projects
# This rolls back the overrides made by the local env for project_awesome
$ cd ..
# Sherpa unloads the local env for projects and restores the global env
# This rolls back the overrides made by the local env for projects
```

### Disable/enable Sherpa

It works only for the current session currently. It will be extended to a global setting.

```shell
$ sherpa disable # aliases: off, disable
Sherpa: All env unloaded. Sherpa goes to sleep.
$ sherpa work # aliases: on, enable
Sherpa: Local env loaded. Sherpa is ready for action.
```

## Configuration

### Local env file

🚧 Comming up

## Cookbook

### Run RSpec in a container or as mortals

```shell
# Dockerized project
# Run RSpec in the `project_with_docker-web` Docker container

# ~/projects/project_with_docker/.local-sherpa
alias de='docker exec -it `docker ps -aqf "name=$(basename $(pwd))-web"`'
alias rs='de rspec'
```

```shell
# Run RSpec as mortals
# ~/projects/project_for_mortals/.local-sherpa
alias rs='bin/rspec'
```

With this config `RSpec` will run depending on in which directory you `cd` into.

### Rails console in production 🤫

```shell
# ~/projects/project_with_heroku/.local-sherpa
alias rc_prod='heroku run rails c -a APP_NAME'

# ~/projects/project_with_aws/.local-sherpa
alias rc_prod='ssh -i /path/key-pair-name.pem user@hostname "/var/app/current/bin/rails console"'
```

### Start your dev environment

```shell
# ~/projects/project_with_docker/.local-sherpa
alias dev='docker-compose -p PROJECT_NAME up -d'
alias dev_stop='docker-compose -p PROJECT_NAME down'

# ~/projects/project_basic/.local-sherpa
alias dev='bin/rails s'
```

## Local development

### Testing

```shell
# Run all the tests for all the supported shells
$ ./test_all

# Run a single test for all the supported shells
$ ./test_all tests/test_sherpa.sh

# Run all the tests for Zsh
$ ./test_zs

# Run a single test for Zsh
$ ./test_zs tests/test_sherpa.sh

# Run all the tests for Bash
$ ./test_bash

# Run a single test for Bash
$ ./test_bash tests/test_sherpa.sh

# Run all the tests for all the supported shells in Ubuntu
$ ./test_all_in_ubuntu
```

### Linting

```shell
$ make lint
```
