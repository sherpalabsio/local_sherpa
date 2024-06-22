# Local Sherpa to the Rescue

## Ascii demo

### Files

```shell
# ~/tmp/.bash_profile
export var_1='ORIGINAL VAR'

alias alias_1='echo "ORIGINAL ALIAS"'

function_1() {
  echo "ORIGINAL FUNCTION"
}

# ~/tmp/projects/project_1/.local-sherpa
export var_1='VAR PROJECT 1'

alias alias_1='echo "ALIAS PROJECT 1"'

function_1() {
  echo "FUNCTION PROJECT 1"
}

# ~/tmp/projects/project_2/.local-sherpa
export var_1='VAR PROJECT 2'

alias alias_1='echo "ALIAS PROJECT 2"'

function_1() {
  echo "FUNCTION PROJECT 2"
}
```

### Show time

```shell
$ cd ~/tmp
$ source .bash_profile
$ echo $var_1 # prints "ORIGINAL VAR"
$ alias_1 # prints "ORIGINAL ALIAS"
$ function_1 # prints "ORIGINAL FUNCTION"

$ cd ~/tmp/projects/project_1
$ echo $var_1 # prints "VAR PROJECT 1"
$ alias_1 # prints "ALIAS PROJECT 1"
$ function_1 # prints "FUNCTION PROJECT 1"

$ cd ~/tmp/projects/project_2
$ echo $var_1 # prints "VAR PROJECT 2"
$ alias_1 # prints "ALIAS PROJECT 2"
$ function_1 # prints "FUNCTION PROJECT 2"

$ cd ~/tmp
$ echo $var_1 # prints "ORIGINAL VAR"
$ alias_1 # prints "ORIGINAL ALIAS"
$ function_1 # prints "ORIGINAL FUNCTION"
```


## Run the tests

`$ ./test.sh`
