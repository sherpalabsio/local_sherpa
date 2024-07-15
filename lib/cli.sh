sherpa() {
  local command="$1"

  local usage_text="Example usage:
  sherpa trust   - Trust the current directory   | aliases: t/allow/grant/permit
  sherpa untrust - Untrust the current directory | aliases: u/disallow/revoke/block/deny
  sherpa edit    - Edit the local env file       | aliases: e/init
  sherpa sleep   - Turn Sherpa off               | aliases: off/disable
  sherpa work    - Turn Sherpa on                | aliases: on/enable

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
  t|trust|allow|grant|permit) _local_sherpa_trust;;
  u|untrust|disallow|revoke|block|deny) _local_sherpa_untrust;;
        e|edit|init) _local_sherpa_edit;;
  sleep|off|disable) _local_sherpa_disable;;
     work|on|enable) _local_sherpa_enable;;
               talk) shift; _local_sherpa_set_log_level "$1";;
              debug) _local_sherpa_set_log_level "debug";;
                shh) _local_sherpa_set_log_level "no talking";;
      s|stat|status) _local_sherpa_print_status;;
           diagnose) _local_sherpa_diagnose;;
                  *) echo "Sherpa doesn't understand what you mean";;
  esac
}

_local_sherpa_trust() {
  _local_sherpa_trust_current_dir && _local_sherpa_load_env_from_current_dir
}

_local_sherpa_untrust() {
  _local_sherpa_unload_env_of_current_dir
  _local_sherpa_untrust_current_dir
}

_local_sherpa_edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR $SHERPA_ENV_FILENAME"
  _local_sherpa_trust_current_dir && _local_sherpa_unload_env_of_current_dir &&
    _local_sherpa_load_env_from_current_dir
}

_local_sherpa_disable() {
  _local_sherpa_unload_all_envs
  _local_sherpa_log_info "All env unloaded. Sherpa goes to sleep."
  _local_sherpa_save_global_config "SHERPA_ENABLED" false
}

_local_sherpa_enable() {
  _local_sherpa_save_global_config "SHERPA_ENABLED" true

  if _local_sherpa_load_env_from_current_dir; then
    local -r current_env_copy="Local env is loaded. "
  fi

  _local_sherpa_log_info "${current_env_copy}Sherpa is ready for action."
}

_local_sherpa_set_log_level() {
  local log_level

  case $1 in
       '') log_level='debug';;
     more) log_level='debug';;
    debug) log_level='debug';;
     info) log_level='info';;
        *) log_level='no talking';;
  esac

  _local_sherpa_save_global_config "SHERPA_LOG_LEVEL" "$log_level"

  log_message="Sherpa: Log level set to: $log_level"
  [ "$log_level" = "no talking" ] && log_message="$log_message 🤫"
  _local_sherpa_log "$log_message"
}

_local_sherpa_diagnose() {
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
