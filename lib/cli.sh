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
  t|trust|allow|grant|permit) trust_current_env && load_current_env;;
  u|untrust|disallow/revoke/block/deny) unload_current_env; untrust_current_env;;
        e|edit|init) edit; trust_current_env; unload_current_env; load_current_env;;
  sleep|off|disable) disable;;
     work|on|enable) enable;;
               talk) shift; set_log_level "$1";;
              debug) set_log_level "debug";;
                shh) set_log_level "no talking";;
      s|stat|status) _show_status;;
           diagnose) diagnose;;
                  *) echo "Sherpa doesn't know what you wish";;
  esac
}

edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR $SHERPA_ENV_FILENAME"
}

disable() {
  unload_all_envs
  log_info "All env unloaded. Sherpa goes to sleep."
  save_global_config "SHERPA_ENABLED" false
}

enable() {
  save_global_config "SHERPA_ENABLED" true

  if load_current_env; then
    copy="Local env is loaded. "
  else
    copy=""
  fi

  log_info "${copy}Sherpa is ready for action."
}

set_log_level() {
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

diagnose() {
  echo "Sherpa is performing a self-assessment. Please wait..."
  echo ""

  if [ -n "$ZSH_VERSION" ]; then
    zsh -i "$SHERPA_PATH/bin/diagnose_zsh"
  else
    # To be able to stub the ~/.bashrc in the tests
    [ -z "$BASHRC_FILE" ] && BASHRC_FILE="$HOME/.bashrc"
    bash --rcfile "$BASHRC_FILE" -i "$SHERPA_PATH/bin/diagnose_bash"
  fi
}
