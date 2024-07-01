setup_cd_hook() {
  if [ -n "$ZSH_VERSION" ]; then
    # ZSH
    function sherpa_chpwd_handler() {
      # Changed directory?
      if [[ -n $OLDPWD && $PWD != $OLDPWD ]]; then
        alert_sherpa_we_changed_dir
      fi
    }

    autoload -U add-zsh-hook
    add-zsh-hook chpwd sherpa_chpwd_handler
  else
    # BASH
    _sherpa_chpwd_hook() {
      # run commands in CHPWD_COMMAND variable on dir change
      if [[ "$PREVPWD" != "$PWD" ]]; then
        alert_sherpa_we_changed_dir
      fi
      # refresh last working dir record
      export PREVPWD="$PWD"
    }

    # add `;` after _sherpa_chpwd_hook if PROMPT_COMMAND is not empty
    PROMPT_COMMAND="_sherpa_chpwd_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
}
