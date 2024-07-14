PATHS_WHERE_LOCAL_ENV_WAS_LOADED=()

alert_sherpa_we_changed_dir() {
  # Skip if Sherpa is disabled
  [ "$SHERPA_ENABLED" = false ] && return
  log_debug "Directory changed."
  unload_inactive_envs
  load_current_env
}

# It unloads the local envs that were loaded in the previous directories that
# we exited from.
unload_inactive_envs() {
  local loaded_paths=()

  for loaded_path in "${PATHS_WHERE_LOCAL_ENV_WAS_LOADED[@]}"; do
    # Select paths not beginning with the current directory
    if [[ $(pwd) != "$loaded_path"* ]]; then
      log_debug "Unload env: $loaded_path"
      varstash_dir="$loaded_path"
      varstash::autounstash
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
    varstash::autounstash
  done

  PATHS_WHERE_LOCAL_ENV_WAS_LOADED=()
}

unload_current_env() {
  varstash_dir="$PWD"
  varstash::autounstash
  smartcd::ashift PATHS_WHERE_LOCAL_ENV_WAS_LOADED > /dev/null
}

load_current_env() {
  # Skip if Sherpa is disabled
  [ "$SHERPA_ENABLED" = false ] && return
  log_debug "Load local env?"

  # Skip if there is no local env file
  [ -f "$SHERPA_ENV_FILENAME" ] || { log_debug "No local env file"; return; }

  # Skip if the env was already loaded
  was_env_loaded && { log_debug "Local env already loaded"; return; }

  # Skip if the local env file is not trusted
  verify_trust || return;

  stash_local_env
  log_debug "Load local env"
  # shellcheck disable=SC1090
  source "$SHERPA_ENV_FILENAME"
  # Append the current directory to the list. This is needed to unload the envs
  # in the right order when we change directories. The root directory should be
  # the last one to unload.
  # shellcheck disable=SC2207
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
  # shellcheck disable=SC2034
  varstash_dir="$PWD"

  while IFS= read -r env_item_name || [[ -n $env_item_name ]]; do
    log_debug "AutoStashing $env_item_name"
    varstash::autostash "$env_item_name"
  done < <(parse_local_env_file)
}
