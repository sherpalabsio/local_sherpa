sherpa() {
  local -r command="$1"

  local usage_text="Example usage:
  sherpa trust          - Trust the current directory   | aliases: t/allow/grant/permit
  sherpa untrust        - Untrust the current directory | aliases: u/disallow/revoke/block/deny
  sherpa edit           - Edit the local env file       | aliases: e/init
  sherpa off            - Turn Sherpa off               | aliases: sleep/disable
  sherpa on             - Turn Sherpa on                | aliases: work/enable
  sherpa symlink [PATH] - Symlink a local env file      | aliases: link/slink
  sherpa reload         - Reload the local env          | aliases: r

Troubleshooting:
  sherpa status   - Show debug status info | aliases: s/stat
  sherpa diagnose - Troubleshoot Sherpa

Log levels:
  sherpa talk more   - Decrease the log level
  sherpa talk less   - Increase the log level
  sherpa talk        - Debug level | Aliases: debug
  sherpa shh         - Silence
  sherpa log [LEVEL] - Set a specific log level | Levels: debug, info, warn, error, silent | Aliases: talk"

  if [ "$USE_SHERPA_DEV_VERSION" = true ]; then
    usage_text="Dev version\n\n$usage_text"
  fi

  case $command in
  -h|--help|help|'') echo "$usage_text";;
  t|trust|allow|grant|permit) _sherpa_cli_trust;;
  u|untrust|disallow|revoke|block|deny) _sherpa_cli_untrust;;
        e|edit|init) _sherpa_cli_edit;;
  off|sleep|disable) _sherpa_cli_disable;;
     on|work|enable) _sherpa_cli_enable;;
           log|talk) shift; _sherpa_cli_set_log_level "$1";;
              debug) _sherpa_cli_set_log_level "$SHERPA_LOG_LEVEL_DEBUG";;
                shh) _sherpa_cli_set_log_level "$SHERPA_LOG_LEVEL_SILENT";;
      s|stat|status) _sherpa_print_status;;
           diagnose) _sherpa_cli_diagnose;;
 symlink|link|slink) _sherpa_cli_symlink "$2";;
           r|reload) _sherpa_cli_reload;;
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
  if [ -z "$EDITOR" ]; then
    _sherpa_log_warn "EDITOR is not set. Falling back to vi."
    vi "$SHERPA_ENV_FILENAME"
  else
    eval "$EDITOR $SHERPA_ENV_FILENAME"
  fi
  _sherpa_trust_current_dir && _sherpa_unload_env_of_current_dir &&
    _sherpa_load_env_from_current_dir
}

_sherpa_cli_disable() {
  _sherpa_unload_all_envs
  _sherpa_log_info "All envs are unloaded. Sherpa goes to sleep."
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
  case $1 in
     less) _sherpa_increase_log_level;;
     more) _sherpa_decrease_log_level;;
       '') _sherpa_set_log_level "$SHERPA_LOG_LEVEL_DEBUG";;
        *) _sherpa_set_log_level "$1";;
  esac

  _sherpa_log "Sherpa: Log level set to: $(_sherpa_get_log_level_in_text)"
}

_sherpa_cli_diagnose() {
  echo "Sherpa is performing a self-assessment..."
  echo ""

  if [ -n "$ZSH_VERSION" ]; then
    zsh -i "$SHERPA_DIR/bin/diagnose_zsh"
  else
    # To be able to stub the ~/.bashrc in the tests
    [ -z "$BASHRC_FILE" ] && BASHRC_FILE="$HOME/.bashrc"
    bash --rcfile "$BASHRC_FILE" -i "$SHERPA_DIR/bin/diagnose_bash"
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

_sherpa_cli_reload() {
  _sherpa_unload_env_of_current_dir && _sherpa_load_env_from_current_dir
}
