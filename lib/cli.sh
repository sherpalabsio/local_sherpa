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
  t|trust|allow|grant|permit) sherpa_cli::trust;;
  u|untrust|disallow/revoke/block/deny) sherpa_cli::untrust;;
        e|edit|init) sherpa_cli::edit;;
  sleep|off|disable) sherpa_cli::disable;;
     work|on|enable) sherpa_cli::enable;;
               talk) shift; sherpa_cli::set_log_level "$1";;
              debug) sherpa_cli::set_log_level "debug";;
                shh) sherpa_cli::set_log_level "no talking";;
      s|stat|status) sherpa_lib::show_status;;
           diagnose) sherpa_cli::diagnose;;
                  *) echo "Sherpa doesn't know what you wish";;
  esac
}

sherpa_cli::trust() {
  trust_current_env && load_current_env
}

sherpa_cli::untrust() {
  unload_current_env
  untrust_current_env
}

sherpa_cli::edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR $SHERPA_ENV_FILENAME"
  trust_current_env && unload_current_env && load_current_env
}

sherpa_cli::disable() {
  unload_all_envs
  log_info "All env unloaded. Sherpa goes to sleep."
  save_global_config "SHERPA_ENABLED" false
}

sherpa_cli::enable() {
  save_global_config "SHERPA_ENABLED" true

  if load_current_env; then
    local -r current_env_copy="Local env is loaded. "
  fi

  log_info "${current_env_copy}Sherpa is ready for action."
}

sherpa_cli::set_log_level() {
  local log_level

  case $1 in
       '') log_level='debug';;
     more) log_level='debug';;
    debug) log_level='debug';;
     info) log_level='info';;
        *) log_level='no talking';;
  esac

  save_global_config "SHERPA_LOG_LEVEL" "$log_level"

  log_message="Sherpa: Log level set to: $log_level"
  [ "$log_level" = "no talking" ] && log_message="$log_message 🤫"
  log "$log_message"
}

sherpa_cli::diagnose() {
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
