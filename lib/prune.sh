_sherpa_prune_permission_files() {
  local checksum_file env_path

  for checksum_file in "$SHERPA_CHECKSUM_DIR"/*; do
    env_path=$(cut -d "|" -f 2 "$checksum_file")

    # Skip if the env exists
    [ -d "$env_path" ] && continue

    _sherpa_log_debug "Remove permission file for: $env_path"
    rm -f "$checksum_file"
  done
}
