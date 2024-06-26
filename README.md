# Local Sherpa to the Rescue

## Demo

```shell
$ cd ~/projects

$ echo $VAR_1
GLOBAL VAR
$ alias_1
GLOBAL ALIAS
$ function_1
GLOBAL FUNCTION

$ cd project_awesome

$ echo $VAR_1
LOCAL VAR PROJECT AWESOME
$ alias_1
LOCAL ALIAS PROJECT AWESOME
$ function_1
LOCAL FUNCTION PROJECT AWESOME

$ cd ..

$ echo $VAR_1
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

## Run RSpec depending on the project setup

```shell
# This project is dockerized
# Run RSpec in the `project_with_docker-web` Docker container

# ~/projects/project_with_docker/.local-sherpa
alias de='docker exec -it `docker ps -aqf "name=$(basename $(pwd))-web"`'
alias rs='de rspec'
```

```shell
# Run RSpec as mortals do
# ~/projects/project_with_mortal_setup/.local-sherpa
alias rs='bin/rspec'
```

With this config `RSpec` will run depending on in which directory you `cd` into.

## Usage
### Config local env
1. $ cd ~/projects/project_awesome
2. $ sherpa edit
3. [Disco](https://www.youtube.com/watch?v=UkSPUDpe0U8)

### Security

By default Sherpa won't load any local env file. You have to mark the directory as trusted first.

``` bash
$ echo "alias rs=rspec" > ~/projects/project_awesome/.local-sherpa
$ cd ~/projects/project_awesome
$ rs
command not found: rs
$ sherpa trust
$ rs
# rspec starts
```

When the local env file changes you have to trust the directory again. But if you use `sherpa edit` to edit the local env file, the directory will be trusted automatically when you save and close the file.

## Supported shells
- Zsh
- More to come

## Installation

```shell
# Clone the repo
$ git clone git@github.com:tothpeter/local_sherpa.git ~/.dotfiles/lib/local_sherpa
# Hook into your shell
$ echo "source ~/.dotfiles/lib/local_sherpa/local_sherpa.sh" >> ~/.zshrc
# Exclude the local env files (.local-sherpa) globally in Git
$ echo ".local-sherpa" >> $(git config --global core.excludesfile)

# Optional but recommended
alias se='sherpa edit'
alias st='sherpa trust'
alias upgrade_sherpa='git -C ~/.dotfiles/lib/local_sherpa pull'
```

## Run the tests

`$ ./test.sh`
