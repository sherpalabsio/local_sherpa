sherpa() {
  local -r command="$1"

  local usage_text="Example usage:
  sherpa trust          - Trust the current directory   | aliases: t/allow/grant/permit
  sherpa untrust        - Untrust the current directory | aliases: u/disallow/revoke/block/deny
  sherpa edit           - Edit the local env file       | aliases: e/init
  sherpa sleep          - Turn Sherpa off               | aliases: off/disable
  sherpa work           - Turn Sherpa on                | aliases: on/enable
  sherpa symlink [PATH] - Symlink a local env file      | aliases: link/slink

Troubleshooting:
  sherpa status   - Show debug status info | aliases: s/stat
  sherpa diagnose - Troubleshoot Sherpa

Tell Sherpa how much to talk:
  sherpa talk [LEVEL] - Set a specific log level | Levels: debug/more, info, no talking/shh/anything else
  sherpa talk         - Everything Sherpa knows
  sherpa debug        - Everything Sherpa knows
  sherpa shh          - Silent Sherpa"

  if [ "$USE_SHERPA_DEV_VERSION" = true ]; then
    usage_text="Dev version\n\n$usage_text"
  fi

  case $command in
  -h|--help|help|'') echo "$usage_text";;
  t|trust|allow|grant|permit) _sherpa_cli_trust;;
  u|untrust|disallow|revoke|block|deny) _sherpa_cli_untrust;;
        e|edit|init) _sherpa_cli_edit;;
  sleep|off|disable) _sherpa_cli_disable;;
     work|on|enable) _sherpa_cli_enable;;
               talk) shift; _sherpa_cli_set_log_level "$1";;
              debug) _sherpa_cli_set_log_level "debug";;
                shh) _sherpa_cli_set_log_level "no talking";;
      s|stat|status) _sherpa_print_status;;
           diagnose) _sherpa_cli_diagnose;;
 symlink|link|slink) _sherpa_cli_symlink "$2";;
                  *) echo "Sherpa doesn't understand what you mean";;
  esac
}

_sherpa_cli_trust() {
  _sherpa_trust_current_dir && _sherpa_load_env_from_current_dir
}

_sherpa_cli_untrust() {
  _sherpa_unload_env_of_current_dir
  _sherpa_untrust_current_dir
}

_sherpa_cli_edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR $SHERPA_ENV_FILENAME"
  _sherpa_trust_current_dir && _sherpa_unload_env_of_current_dir &&
    _sherpa_load_env_from_current_dir
}

_sherpa_cli_disable() {
  _sherpa_unload_all_envs
  _sherpa_log_info "All env unloaded. Sherpa goes to sleep."
  _sherpa_save_global_config "SHERPA_ENABLED" false
}

_sherpa_cli_enable() {
  _sherpa_save_global_config "SHERPA_ENABLED" true

  if _sherpa_load_env_from_current_dir; then
    local -r current_env_copy="Local env is loaded. "
  fi

  _sherpa_log_info "${current_env_copy}Sherpa is ready for action."
}

_sherpa_cli_set_log_level() {
  local log_level

  case $1 in
       '') log_level='debug';;
     more) log_level='debug';;
    debug) log_level='debug';;
     info) log_level='info';;
        *) log_level='no talking';;
  esac

  _sherpa_save_global_config "SHERPA_LOG_LEVEL" "$log_level"

  log_message="Sherpa: Log level set to: $log_level"
  [ "$log_level" = "no talking" ] && log_message="$log_message 🤫"
  _sherpa_log "$log_message"
}

_sherpa_cli_diagnose() {
  echo "Sherpa is performing a self-assessment..."
  echo ""

  if [ -n "$ZSH_VERSION" ]; then
    zsh -i "$SHERPA_PATH/bin/diagnose_zsh"
  else
    # To be able to stub the ~/.bashrc in the tests
    [ -z "$BASHRC_FILE" ] && BASHRC_FILE="$HOME/.bashrc"
    bash --rcfile "$BASHRC_FILE" -i "$SHERPA_PATH/bin/diagnose_bash"
  fi
}

_sherpa_cli_symlink() {
  local -r symlink_target="$1"

  if [ -f "$SHERPA_ENV_FILENAME" ]; then
    _sherpa_log_error "There is already a local env file in this directory." \
                            "Remove it before symlinking a new one."
    return 1
  fi

  if [ ! -e "$symlink_target" ]; then
    _sherpa_log_error "The target doesn't exist: $symlink_target"
    return 1
  fi

  if [ -d "$symlink_target" ]; then
    ln -s "$symlink_target/$SHERPA_ENV_FILENAME" "$SHERPA_ENV_FILENAME"
  else
    ln -s "$symlink_target" "$SHERPA_ENV_FILENAME"
  fi

  _sherpa_cli_trust > /dev/null &&
    _sherpa_log_info "Symlink is created. Local env is loaded."
}
