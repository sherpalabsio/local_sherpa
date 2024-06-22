#!/usr/bin/env zsh

SHERPA_PATH=$(dirname "$(dirname "$0")")

# Load dependencies
source "$SHERPA_PATH/vendor/smartcd/arrays"
source "$SHERPA_PATH/vendor/smartcd/smartcd"
source "$SHERPA_PATH/vendor/smartcd/varstash"

# Load sherpa
source "$SHERPA_PATH/lib/sherpa.zsh"

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
