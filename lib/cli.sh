sherpa() {
  local -r usage_text="Basic usage:
  trust          - Trust the current directory   | Aliases: t, allow, grant, permit
  untrust        - Untrust the current directory | Aliases: u, disallow, revoke, block, deny
  edit           - Edit the current env file     | Aliases: e, init
  palette        - Command palette for the local env (experimental) | Alias: :
  off            - Turn Sherpa off               | Aliases: disable, sleep
  on             - Turn Sherpa on                | Aliases: enable, work
  symlink [PATH] - Symlink the current env file  | Aliases: link, slink
  dump           - Dump the current env file to a .envrc.example file
  reload         - Reload the current env        | Alias: r
  prune          - Remove permissions for non-existing directories
  update         - Update to the latest version
  support        - Help me buy a Caribbean island

Troubleshooting:
  status   - Show debug status info | Aliases: s, stat
  debug    - Show debug status info
  diagnose - Run local and global tests

Log level - Set how much Sherpa talks:
  talk      - Open the options menu  | Alias: log
  talk more - Decrease the log level | Alias: -
  talk less - Increase the log level | Alias: +
  shh       - Silence

Version: $SHERPA_VERSION

Created by \e]8;;https://github.com/SherpaLabsIO\e\\Peter Toth @ SherpaLabsIO\e]8;;\e\\"

  local -r command="$1"
  case $command in
              t | trust | allow | grant | permit) _sherpa_cli_trust ;;
  u | untrust | disallow | revoke | block | deny) _sherpa_cli_untrust ;;
                                 e | edit | init) _sherpa_cli_edit ;;
                           off | sleep | disable) _sherpa_cli_disable ;;
                              on | work | enable) _sherpa_cli_enable ;;
                                      log | talk) _sherpa_cli_set_log_level "$2" ;;
                                             shh) _sherpa_cli_set_log_level "$SHERPA_LOG_LEVEL_SILENT" ;;
                               s | stat | status) _sherpa_cli_status ;;
                                        diagnose) _sherpa_cli_diagnose ;;
                          symlink | link | slink) _sherpa_cli_symlink "$2" ;;
                                            dump) _sherpa_cli_dump_current_env ;;
                                      r | reload) _sherpa_cli_reload ;;
                                    : |  palette) _sherpa_cli_command_palette ;;
                                           prune) _sherpa_prune_permission_files ;;
                                          update) _sherpa_update_system ;;
                                           debug) _sherpa_print_debug_info ;;
                                         support) _sherpa_cli_support ;;
                        -v | --version | version) echo "$SHERPA_VERSION" ;;
                         -h | --help | help | "") echo -e "$usage_text" ;;
                                               *) echo "Sherpa doesn't understand what you mean" ;;
  esac
}

_sherpa_cli_trust() {
  _sherpa_trust_current_dir && _sherpa_cli_reload
}

_sherpa_cli_untrust() {
  _sherpa_unload_env_of_current_dir
  _sherpa_untrust_current_dir
}

_sherpa_cli_edit() {
  _sherpa_log "Sherpa: Waiting for your editor to close the file..."

  if [ -z "$EDITOR" ]; then
    _sherpa_log_warn "\$EDITOR env var is not set. Falling back to vi."
    vi "$SHERPA_ENV_FILENAME"
  else
    eval "$EDITOR $SHERPA_ENV_FILENAME"
    __sherpa_cli_clear_last_lines 1
  fi

  # The user cancelled the init (didn't save the file)
  [ -f "$SHERPA_ENV_FILENAME" ] || return 1

  _sherpa_trust_current_dir &&
    _sherpa_unload_env_of_current_dir &&
    _sherpa_load_env_for_current_dir &&
    _sherpa_auto_dump_current_env
}

_sherpa_cli_disable() {
  _sherpa_unload_all_envs
  _sherpa_log_info "All envs are unloaded. Sherpa goes to sleep."
  _sherpa_save_global_config "SHERPA_ENABLED" false
}

_sherpa_cli_enable() {
  _sherpa_save_global_config "SHERPA_ENABLED" true

  if _sherpa_load_env_for_current_dir; then
    local -r current_env_copy="Env is loaded. "
  fi

  _sherpa_log_info "${current_env_copy}Sherpa is ready for action."
}

_sherpa_cli_set_log_level() {
  case $1 in
   less | -) _sherpa_increase_log_level ;;
   more | +) _sherpa_decrease_log_level ;;
         "") __sherpa_log_level_menu ;;
          *) _sherpa_set_log_level "$1" ;;
  esac

  # Don't change the log level if the user ctrl-c'd the menu
  # shellcheck disable=SC2181
  [ $? -ne 0 ] && return 1

  _sherpa_log "Sherpa: Log level set to: $(_sherpa_get_log_level_in_text)"
}

__sherpa_cli_clear_last_lines() {
  local -r number_of_lines_to_clear=$1

  echo -en "\033[2K"
  echo -en "\r"

  for _ in $(seq "$number_of_lines_to_clear"); do
    echo -en "\033[1A"
    echo -en "\033[2K"
  done
}

_sherpa_cli_status() {
  source "$SHERPA_DIR/lib/status.sh"
  _sherpa_print_status
}

_sherpa_cli_diagnose() {
  if [ -n "$ZSH_VERSION" ]; then
    zsh -i "$SHERPA_DIR/bin/diagnose"
  else
    BASHRC_FILE="$BASHRC_FILE" bash -i "$SHERPA_DIR/bin/diagnose"
  fi
}

_sherpa_cli_symlink() {
  local -r symlink_target="$1"

  if [ -f "$SHERPA_ENV_FILENAME" ]; then
    _sherpa_log_error "There is already an env file in this directory." \
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
    _sherpa_log_info "Symlink is created. Env is loaded."
}

_sherpa_cli_dump_current_env() {
  _sherpa_dump_current_env
  _sherpa_log_info "Env file is dumped to $SHERPA_ENV_FILENAME.example"
}

_sherpa_cli_reload() {
  _sherpa_unload_env_of_current_dir && _sherpa_load_env_for_current_dir
}

_sherpa_cli_command_palette() {
  if [ ! -f "$SHERPA_ENV_FILENAME" ]; then
    echo "There is no local env file"
    return 1
  fi

  # Warn the user if fzf is not installed
  if ! command -v fzf > /dev/null; then
    _sherpa_log_error "fzf is not installed. Please install it to use this feature."
    return 1
  fi

  local -r fzf_major_version=$(fzf --version | awk -F. '{print $1}')
  local -r fzf_minor_version=$(fzf --version | awk -F. '{print $2}')

  # Warn the user if fzf version is not supported
  if [[ "$fzf_major_version" -eq 0 && "$fzf_minor_version" -lt 42 ]]; then
    _sherpa_log_error "fzf version is less than 0.42.0. Please upgrade it to use this feature."
    return 1
  fi

  _sherpa_command_palette
}

_sherpa_cli_support() {
  echo "Thank you for using Sherpa! 🙏"
  echo "To support the project just star it on GitHub: https://github.com/SherpaLabsIO/local_sherpa"
}

_sherpa_auto_dump_current_env() {
  # Check if the feature is enabled
  [ "$SHERPA_DUMP_ENV_ON_EDIT" != true ] && return

  _sherpa_dump_current_env
}
