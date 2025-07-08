<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="media/logo_dark_mode.svg">
    <img alt="Logo" src="media/logo_light_mode.svg" width="355">
  </picture>
</p>

----------

[![CI](https://github.com/sherpalabsio/local_sherpa/actions/workflows/ci.yml/badge.svg)](https://github.com/sherpalabsio/local_sherpa/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/Version-0.2.1-2e3436.svg)
[![Supportedshells](https://img.shields.io/badge/Supported_shells-Zsh,_Bash-2e3436.svg)](#supported-shells)

## Define folder specific aliases, functions and variables in your shell

Sherpa is a shell extension that allows you to define new or override existing aliases, functions or variables on a per-folder basis, with support for nesting.

It's similar to [Direnv](https://github.com/direnv/direnv), but with fewer features and added support for aliases and functions.

## ASCII Demo

```sh
$ cd ~/projects

$ c # short for console
# IRB (Interactive Ruby Shell) starts
# ctrl + d to exit

$ cd ~/projects/project_elixir
$ c
# IEx (Interactive Elixir) starts
# ctrl + c to exit

$ cd ~/projects/project_postgres
$ c
# Docker container with Postgres starts
# PSQL (PostgreSQL interactive terminal) in the container starts
```

The above is accomplished with the help of Sherpa and the files below.

```sh
# ~/.zshrc or ~/.bashrc
alias c='irb'

# ~/projects/project_elixir/.envrc
alias c='iex'

# ~/projects/project_postgres/.envrc
c() {
  # Start the Postgres container if it's not running
  [ -z "$(docker compose ps -q)" ] && docker compose up -d
  docker compose exec db psql -U postgres
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
- Ubuntu 22.04
- Ubuntu 24.04

## Installation

### Homebrew

```sh
brew install sherpalabsio/sherpalabsio/local_sherpa
```

### Automated

```sh
curl -s https://raw.githubusercontent.com/sherpalabsio/local_sherpa/main/scripts/install.sh | bash
```

This script will automatically:
- Install the latest version to `~/.local/lib`
- Symlink the `init` file to `~/.local/bin/local_sherpa_init`
- Add `~/.local/bin` to your `PATH` (if not already present)
- Configure your shell profile (`~/.zshrc` or `~/.bashrc`) to initialize Sherpa

### Manual

- Download a release (local_sherpa_X.X.X.tar.gz) from the [releases page](https://github.com/sherpalabsio/local_sherpa/releases)
- Symlink the `init` file as `local_sherpa_init` somewhere in your `PATH`
- Add `eval "$(local_sherpa_init)"` to your shell profile (e.g. `~/.zshrc`, `~/.bashrc`)

### Git configuration

Exclude the env files (.envrc) globally so you won't commit them by mistake.

```sh
echo ".envrc" >> $(git config --global core.excludesfile)
```

## Upgrading to the latest version

`$ sherpa update`

## Features

See the full list of commands by running `$ sherpa` in your shell.

### Security

Sherpa won't load any env file unless you trust it first (`$ sherpa trust`).\
This is to prevent running unknown code when you `cd` into a directory.

When an env file changes you have to trust it again unless you edited it
with `$ sherpa edit` which trusts and reloads the env file after you close it
in your editor.

You can untrust an env file with `sherpa untrust`.

### Command palette with fuzzy finder for the local env (experimental)

`$ sherpa palette`

![demo](https://github.com/user-attachments/assets/3e398ec5-cf77-460e-83ee-3af5036f4c72)

It requires [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#installation).

Offers a list of available commands and variables in the current env.\
Select a command hit enter then hit enter again to run it.

The list can be less accurate if the dynamic env file parsing is not enabled.
Enable it by setting the `SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING` environment variable to `true`.

#### Bind it to Shift + Command + P:

Make sure your terminal sends the same escape sequence (`^[[114;9u`)
as you use to bind the palette command.

```sh
# Zsh (~/.zshrc)
__sherpa_palette() {
  sherpa palette
}

zle -N __sherpa_palette
bindkey "^[[114;9u" __sherpa_palette
# For tmux: bindkey "^[r" __sherpa_palette

# Bash (~/.bashrc)
__sherpa_palette() {
  sherpa palette
}

bind -x '"\e[114;9u":__sherpa_palette'
```

### Env loading and unloading

- Sherpa loads the env from a `.envrc` file when you `cd` into a directory
  - It sources the env file meaning its whole content is executed in the current shell
  - It overrides the existing aliases, functions and variables
- Sherpa unloads the env when you leave a directory
  - It removes the newly added aliases, functions and variables
  - It restores the overridden items to their previous state
  - Going into a subdirectory does not unload the env of the parent directory
- Sherpa partially supports nested envs
  - Loading parent envs is not supported you have to `cd` into the parent directory first

### Dynamic env loading and unloading (experimental)

Non exported variables and dynamically created entities are unloaded only if the
`SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING` environment variable is set to `true`.

This can slow down `cd` because Sherpa executes the env file in a subshell
three times when you `cd` into a directory.

### Aliases and functions in the env file taking precedence

Declaring a function in the env file with the same name as an existing alias
will override the alias automatically. No need to call `unalias`.\
The same applies to declaring aliases in the env
file with the same name as existing functions.

### Loading envs from parent directories automatically

This is not supported currently. Feel free to open a feature request.

### Running a script when leaving a directory

This is not supported currently. Feel free to open a feature request.\
Alternatively, you can use: https://github.com/hyperupcall/autoenv

## Configuration

Set these environment variables to configure Sherpa's behavior:

```sh
export SHERPA_ENV_FILENAME='.env' # Default: .envrc
# To support unloading non-exported variables and dynamically created shell entities
export SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING=true
# To auto dump the env into a .envrc.example file when running `sherpa edit`
export SHERPA_DUMP_ENV_ON_EDIT=true
```

## Settings

### Log level

It affects only the current and new terminal sessions.

```sh
$ sherpa talk more # - Decrease the log level | Alias: -
$ sherpa talk less # - Increase the log level | Alias: +
$ sherpa shh       # - Silence
```

### Disable/enable Sherpa

It affects only the current and new terminal sessions.

```sh
$ sherpa off # aliases: sleep, disable
Sherpa: All envs are unloaded. Sherpa goes to sleep.
$ sherpa on # aliases: work, enable
Sherpa: Env is loaded. Sherpa is ready for action.
```

## Cookbook

### Run tests using the same shortcut across different projects

```sh
# ~/projects/project_ruby_with_docker/.envrc
alias t='docker exec -it project-awesome-api rspec'

# ~/projects/project_elixir/.envrc
alias t='mix test'

# ~/projects/project_js/.envrc
alias t='yarn test'
```

### Rails console in production 🤫

```sh
# ~/projects/project_with_heroku/.envrc
alias rc_prod='heroku run rails c -a APP_NAME'

# ~/projects/project_with_aws/.envrc
alias rc_prod='ssh -i /path/key-pair-name.pem user@hostname "/var/app/current/bin/rails console"'
```

### Start your dev environment

```sh
# ~/projects/project_with_docker/.envrc
alias up='docker compose up -d'
alias upb='docker compose up --build -d'
alias down='docker compose down'

# ~/projects/project_basic/.envrc
alias up='bin/rails s'
```

## Troubleshooting

```sh
$ sherpa status
$ sherpa debug
$ sherpa diagnose
```

## Local development

### Testing

All *_test.sh files are run recursively from the tests directory.

Replace `$ make test` with `$ make test_zsh` or `$ make test_bash` to run the tests for a specific shell.

```sh
# Run all the tests for all the supported shells
$ make test

# Run a single test for all the supported shells
$ make test tests/features/edit_test.sh

# Run all the tests from a folder for all the supported shells
$ make test tests/features

# Run all the tests for all the supported shells in Ubuntu
$ make test_all_in_ubuntu

# Run a single test for all the supported shells in Ubuntu
$ make test_all_in_ubuntu tests/features/edit_test.sh

# Test the performance for all the supported shells
# It is not a real test, it is more like a benchmark
$ make test_performance
```

### Linting

```sh
$ make lint
```

## Credits

The core functionality (var, func and alias stashing) of this project was inspired by [Varstash](https://github.com/cxreg/smartcd?tab=readme-ov-file#varstash).

Special thanks to its author:
- Dave Olszewski <cxreg@pobox.com>
