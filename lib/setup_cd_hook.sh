_local_sherpa_setup_cd_hook() {
  if [ -n "$ZSH_VERSION" ]; then
    # ======== ZSH ========
    # shellcheck disable=SC2317
    _local_sherpa_chpwd_handler() {
      # Changed directory?
      if [[ -n $OLDPWD && $PWD != "$OLDPWD" ]]; then
        _local_sherpa_alert_sherpa_we_changed_dir
      fi
    }

    autoload -U add-zsh-hook
    add-zsh-hook chpwd _local_sherpa_chpwd_handler
  else
    # ======== BASH ========
    # shellcheck disable=SC2317
    _local_sherpa_chpwd_handler() {
      # Filter for directory change
      if [[ "$PREVPWD" != "$PWD" ]]; then
        _local_sherpa_alert_sherpa_we_changed_dir
      fi

      export PREVPWD="$PWD"
    }

    # add `;` after _local_sherpa_chpwd_handler if PROMPT_COMMAND is not empty
    PROMPT_COMMAND="_local_sherpa_chpwd_handler${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
}
