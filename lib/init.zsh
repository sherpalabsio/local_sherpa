#!/usr/bin/env zsh

SCRIPT_DIR=`dirname $0`

# Load dependencies
source "$SCRIPT_DIR/../vendor/smartcd/arrays"
source "$SCRIPT_DIR/../vendor/smartcd/smartcd"
source "$SCRIPT_DIR/../vendor/smartcd/varstash"

# Load sherpa
source "$SCRIPT_DIR/../lib/sherpa.zsh"

function sherpa_chpwd_handler() {
  # Changed directory?
  if [[ -n $OLDPWD && $PWD != $OLDPWD ]]; then
    alert_sherpa
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd sherpa_chpwd_handler

# When loading the shell, we need to make sure that the sherpa is active
alert_sherpa
