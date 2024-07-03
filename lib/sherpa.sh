function sherpa() {
  local command="$1"

  local usage_text="Example usage:
  sherpa trust|allow      - Trust the local env file (short-cut alias: \"t\")
  sherpa untrust          - Untrust the local env file (short-cut alias: \"u\")
  sherpa edit|init        - Edit the local env file (short-cut alias: \"e\")
  sherpa rest|off|disable - Turn Sherpa off for the current session
  sherpa work|on|enable   - Turn Sherpa on for the current session

Tell sherpa how much he should talk (works only for the current session):
  sherpa info               - Messages like the local env file is not trusted etc.
  sherpa debug              - Everything Sherpa knows
  sherpa shh|shhh           - Shotup Sherpa
  sherpa talk               - Set the log level to the specified value (debug, info, no talking)"

  case $command in
 -h|--help|help|'') echo "$usage_text";;
     t|trust|allow) trust_current_env; load_current_env;;
         u|untrust) unload_current_env; untrust_current_env;;
       e|edit|init) edit; trust_current_env; unload_current_env; load_current_env;;
  rest|off|disable) disable;;
    work|on|enable) enable;;
              talk) shift; set_log_level $1;;
             debug) set_log_level "debug";;
              info) set_log_level "info";;
          shh|shhh) set_log_level "no talking";;
  esac
}

edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR .local-sherpa"
}

disable() {
  unload_all_envs
  log_info "All env unloaded. Sherpa goes to sleep."
  unset SHERPA_ENABLED
}

enable() {
  export SHERPA_ENABLED=true
  load_current_env
  log_info "Local env loaded. Sherpa is ready for action."
}

set_log_level() {
  case $1 in
    debug) SHERPA_LOG_LEVEL='debug';;
    info) SHERPA_LOG_LEVEL='info';;
    *) SHERPA_LOG_LEVEL='no talking';;
  esac
  log_message="Sherpa: Log level set to: $SHERPA_LOG_LEVEL"
  [ "$SHERPA_LOG_LEVEL" = "no talking" ] && log_message="$log_message 🤫"
  log "$log_message"
}

alert_sherpa_we_changed_dir() {
  # Skip if Sherpa is disabled
  [ -z "$SHERPA_ENABLED" ] && return
  log_debug "Directory changed."
  unload_inactive_envs
  load_current_env
}

PATHS_WHERE_LOCAL_ENV_WAS_LOADED=()

# It unloads the local envs that were loaded in the previous directories that
# we exited from.
unload_inactive_envs() {
  local loaded_paths=()

  for loaded_path in "${PATHS_WHERE_LOCAL_ENV_WAS_LOADED[@]}"; do
    # Select paths not beginning with the current directory
    if [[ $(pwd) != "$loaded_path"* ]]; then
      log_debug "Unload env: $loaded_path"
      varstash_dir="$loaded_path"
      autounstash
    else
      loaded_paths+=("$loaded_path")
    fi
  done

  PATHS_WHERE_LOCAL_ENV_WAS_LOADED=("${loaded_paths[@]}")
}

unload_all_envs() {
  for loaded_path in "${PATHS_WHERE_LOCAL_ENV_WAS_LOADED[@]}"; do
    log_debug "Unload env: $loaded_path"
    varstash_dir="$loaded_path"
    autounstash
  done

  PATHS_WHERE_LOCAL_ENV_WAS_LOADED=()
}

unload_current_env() {
  varstash_dir="$PWD"
  autounstash
  ashift PATHS_WHERE_LOCAL_ENV_WAS_LOADED
}

load_current_env() {
  # Skip if Sherpa is disabled
  [ -z "$SHERPA_ENABLED" ] && return
  log_debug "Load local env?"

  # Skip if there is no local env file
  [ -f .local-sherpa ] || { log_debug "No local env file"; return; }

  # Skip if the env was already loaded
  was_env_loaded && { log_debug "Local env already loaded"; return; }

  # Skip if the local env file is not trusted
  verify_trust || return;

  stash_local_env
  log_debug "Load local env"
  source .local-sherpa
  # Append the current directory to the list. This is needed to unload the envs
  # in the right order when we change directories. The root directory should be
  # the last one to unload.
  PATHS_WHERE_LOCAL_ENV_WAS_LOADED=($(pwd) "${PATHS_WHERE_LOCAL_ENV_WAS_LOADED[@]}")
}

was_env_loaded() {
  for loaded_path in "${PATHS_WHERE_LOCAL_ENV_WAS_LOADED[@]}"; do
    if [[ "$loaded_path" == $(pwd) ]]; then
      return 0
    fi
  done

  return 1
}

stash_local_env() {
  log_debug "Stash local env"
  varstash_dir="$PWD"

  while IFS= read -r env_item_name || [[ -n $env_item_name ]]; do
    log_debug "AutoStashing $env_item_name"
    autostash "$env_item_name"
  done < <(parse_local_env_file)
}
