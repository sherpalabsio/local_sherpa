# Sherpa - Project based development environment

Sherpa carries your local environment settings for you as you `cd` through projects, space and time.

## Status

🚧 Unstable, under active development.

[![example workflow](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml/badge.svg)](https://github.com/tothpeter/local_sherpa/actions/workflows/ci.yml)

## Demo - Core functionality

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
# ~/projects/project_awesome/.sherparc
export VAR_1="LOCAL VAR PROJECT AWESOME"

alias alias_1='echo "LOCAL ALIAS PROJECT AWESOME"'

function_1() {
  echo "LOCAL FUNCTION PROJECT AWESOME"
}
```

## Usage
### Config local env
1. $ cd ~/projects/project_awesome
2. $ sherpa edit
3. [Disco](https://www.youtube.com/watch?v=UkSPUDpe0U8)

For more details see the [Features](#features) section.

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

## Side effect

When sherpa loads the local env, it sources the local env file meaning its
whole content is executed in the current shell.

## Installation

```shell
# Clone the repo
$ git clone git@github.com:tothpeter/local_sherpa.git ~/.dotfiles/lib/local_sherpa
# Hook it into your shell
$ echo "source ~/.dotfiles/lib/local_sherpa/local_sherpa.sh" >> ~/.zshrc
# Exclude the local env files (.sherparc) globally in Git
$ echo ".sherparc" >> $(git config --global core.excludesfile)

# Optional but recommended
alias se='sherpa edit'
alias st='sherpa trust'
alias upgrade_sherpa='git -C ~/.dotfiles/lib/local_sherpa pull'
```

## Features

See the full list of commands by running `$ sherpa` in your shell.

### Security

Sherpa won't load any local env file unless you trust the directory first.
This is to prevent running malicious code when you `cd` into a directory.

``` bash
$ echo "alias rs=rspec" > ~/projects/project_awesome/.sherparc
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

### Loading envs from parent directories automatically

It is not supported currently. Feel free to open a feature request.

### Env loading and unloading

- Sherpa supports nested envs
  - It unload the envs in the correct order to restore the overridden items.
- Sherpa does not unload the loaded envs when you `cd` into a subdirectory.

#### Demo

```shell
# Given the following directory structure with the corresponding local env files
# ~/projects/.sherparc
# ~/projects/project_awesome/.sherparc
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

It affects only the current and new terminal sessions.

```shell
$ sherpa sleep # aliases: off, disable
Sherpa: All env unloaded. Sherpa goes to sleep.
$ sherpa work # aliases: on, enable
Sherpa: Local env is loaded. Sherpa is ready for action.
```

### Running a script when leaving a directory

It is not supported currently. Feel free to open a feature request.\
Alternatively, you can use: https://github.com/hyperupcall/autoenv

## Configuration

Set the following environment variables anywhere to instruct Sherpa on how
to operate.

```shell
export SHERPA_ENABLED=false # Default: true
export SHERPA_ENV_FILENAME='.envrc' # Default: .sherparc
# Control how much Sherpa talks
export SHERPA_LOG_LEVEL='no talking' # Default: info | Values: debug, info, no talking
```

## Cookbook

### Run RSpec in a container or else

```shell
# Run RSpec in the `project-awesome-api` Docker container

# ~/projects/project_awesome_api/.sherparc
alias de='docker exec -it project-awesome-api'
alias rs='de rspec'
```

```shell
# Run RSpec on the host machine

# ~/projects/project_for_mortals/.sherparc
alias rs='bin/rspec'
```

With this config `RSpec` will run depending on in which directory you `cd` into.

### Run the tests the same way in different projects

```shell
# ~/projects/project_ruby_with_docker/.sherparc
alias t='docker exec -it project-awesome-api rspec'

# ~/projects/project_elixir/.sherparc
alias t='mix test'

# ~/projects/project_js_with_jest/.sherparc
alias t='yarn test'
```

With this config `RSpec` will run depending on in which directory you `cd` into.

### Rails console in production 🤫

```shell
# ~/projects/project_with_heroku/.sherparc
alias rc_prod='heroku run rails c -a APP_NAME'

# ~/projects/project_with_aws/.sherparc
alias rc_prod='ssh -i /path/key-pair-name.pem user@hostname "/var/app/current/bin/rails console"'
```

### Start your dev environment

```shell
# ~/projects/project_with_docker/.sherparc
alias up='docker-compose up -d'
alias upb='docker-compose up --build -d'
alias down='docker-compose down'

# ~/projects/project_basic/.sherparc
alias up='bin/rails s'
```

## Troubleshooting

```shell
$ sherpa diagnose
```

## Local development

### Testing

All *_test.sh files are run recursively from the tests directory.

```shell
# Run all the tests for all the supported shells
$ make test

# Run a single test for all the supported shells
$ make test tests/features/edit_test.sh

# Run all the tests for Zsh
$ make test_zs

# Run a single test for Zsh
$ make test_zs tests/features/edit_test.sh

# Run all the tests for Bash
$ make test_bash

# Run a single test for Bash
$ make test_bash tests/features/edit_test.sh

# Run all the tests for all the supported shells in Ubuntu
$ make test_all_in_ubuntu

# Run a single for all the supported shells in Ubuntu
$ make test_all_in_ubuntu tests/features/edit_test.sh
```

### Linting

```shell
$ make lint
```

## Credits

This project uses the [varstash](https://github.com/cxreg/smartcd?tab=readme-ov-file#varstash)
library from [smartcd](https://github.com/cxreg/smartcd),
which is licensed under the Artistic License.

Special thanks to the original author:
- Dave Olszewski <cxreg@pobox.com>

The varstash library is modified to fit the needs of this project.
