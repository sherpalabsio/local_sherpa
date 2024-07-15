_local_sherpa_alert_sherpa_we_changed_dir() {
  # Skip if Sherpa is disabled
  [ "$SHERPA_ENABLED" = false ] && return
  _local_sherpa_log_debug "Directory changed."
  _local_sherpa_unload_envs_of_exited_dirs
  _local_sherpa_load_env_from_current_dir
}

# It unloads the loaded envs of previous directories that we exited.
_local_sherpa_unload_envs_of_exited_dirs() {
  local loaded_paths=()

  for loaded_path in "${SHERPA_LOADED_ENV_DIRS[@]}"; do
    # Select paths not beginning with the current directory
    if [[ $(pwd) != "$loaded_path"* ]]; then
      _local_sherpa_log_debug "Unload env: $loaded_path"
      varstash_dir="$loaded_path"
      varstash::autounstash
    else
      loaded_paths+=("$loaded_path")
    fi
  done

  SHERPA_LOADED_ENV_DIRS=("${loaded_paths[@]}")
}

_local_sherpa_unload_all_envs() {
  for loaded_path in "${SHERPA_LOADED_ENV_DIRS[@]}"; do
    _local_sherpa_log_debug "Unload env: $loaded_path"
    varstash_dir="$loaded_path"
    varstash::autounstash
  done

  SHERPA_LOADED_ENV_DIRS=()
}

_local_sherpa_unload_env_of_current_dir() {
  varstash_dir="$PWD"
  varstash::autounstash
  smartcd::ashift SHERPA_LOADED_ENV_DIRS > /dev/null
}

_local_sherpa_load_env_from_current_dir() {
  # Skip if Sherpa is disabled
  [ "$SHERPA_ENABLED" = false ] && return
  _local_sherpa_log_debug "Load local env?"

  # Skip if there is no local env file
  [ -f "$SHERPA_ENV_FILENAME" ] || { _local_sherpa_log_debug "No local env file"; return; }

  # Skip if the env was already loaded
  _local_sherpa_was_env_loaded && { _local_sherpa_log_debug "Local env already loaded"; return; }

  # Skip if the local env file is not trusted
  _local_sherpa_verify_trust || return;

  _local_sherpa_stash_local_env
  _local_sherpa_log_debug "Load local env"
  # shellcheck disable=SC1090
  source "$SHERPA_ENV_FILENAME"
  # Append the current directory to the list. This is needed to unload the envs
  # in the right order when we change directories. The root directory should be
  # the last one to unload.
  # shellcheck disable=SC2207
  SHERPA_LOADED_ENV_DIRS=($(pwd) "${SHERPA_LOADED_ENV_DIRS[@]}")
}

_local_sherpa_was_env_loaded() {
  for loaded_path in "${SHERPA_LOADED_ENV_DIRS[@]}"; do
    if [[ "$loaded_path" == $(pwd) ]]; then
      return 0
    fi
  done

  return 1
}

_local_sherpa_stash_local_env() {
  _local_sherpa_log_debug "Stash local env"
  # shellcheck disable=SC2034
  varstash_dir="$PWD"

  while IFS= read -r env_item_name || [[ -n $env_item_name ]]; do
    _local_sherpa_log_debug "AutoStashing $env_item_name"
    varstash::autostash "$env_item_name"
  done < <(_local_sherpa_parse_local_env_file)
}
