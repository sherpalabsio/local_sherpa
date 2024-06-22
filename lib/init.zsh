#!/usr/bin/env zsh

SCRIPT_DIR=`dirname $0`

source "$SCRIPT_DIR/../vendor/smartcd/arrays"
source "$SCRIPT_DIR/../vendor/smartcd/smartcd"
source "$SCRIPT_DIR/../vendor/smartcd/varstash"

function chpwd() {
  if [[ -n $OLDPWD && $PWD != $OLDPWD ]]; then
    varstash_dir=$OLDPWD
    unload_previous_local_config $OLDPWD
    varstash_dir=$PWD
    load_local_config $PWD
  fi
  export OLDPWD=$PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd

unload_previous_local_config() {
  autounstash
  echo "Config unloaded."
}

load_local_config() {
  if [ -f .local-sherpa ]; then
    stash_local_config
    source .local-sherpa
    echo "Config loaded."
  fi
}

stash_local_config() {
  local file_to_parse=".local-sherpa"

  # Stash variables
  grep -o '^\s*export\s\+\([^=]\+\)' "$file_to_parse" | while read -r line; do
    variable_name=$(echo "$line" | awk '{print $2}')
    autostash "$variable_name"
  done

  # Stash aliases
  grep -o '^\s*alias\s\+\([^=]\+\)' "$file_to_parse" | while read -r line; do
    alias=$(echo "$line" | awk '{print $2}')
    autostash $alias
  done

  # Stash functions
  grep -o '^\s*\([^()]\+\)\s*()' "$file_to_parse" | while read -r line; do
    function_name=$(echo "$line" | sed 's/^\s*//; s/\s*()//')
    autostash "$function_name"
  done
}
