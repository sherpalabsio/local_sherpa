#!/usr/bin/env zsh

export SHERPA_ENABLED=true

SHERPA_PATH=$( cd -- "$(dirname "$(dirname "$0")")" >/dev/null 2>&1 ; pwd -P )
SHERPA_CHECKSUM_DIR="$HOME/.local/share/local_sherpa"
SHERPA_LOG_LEVEL='info' # debug, info, nothing

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
