_sherpa_prune_permission_files() {
  local checksum_file env_path
  local obsolete_env_paths=()

  for checksum_file in "$SHERPA_CHECKSUM_DIR"/*; do
    env_path=$(cut -d "|" -f 2 "$checksum_file")

    # Skip if the env exists
    [ -d "$env_path" ] && continue

    rm -f "$checksum_file"
    obsolete_env_paths+=("$env_path")
  done

  if [ ${#obsolete_env_paths[@]} -eq 0 ]; then
    echo "Nothing to prune."
  else
    echo "Removed permissions for non-existing directories:"
    for env_path in "${obsolete_env_paths[@]}"; do
      echo "- $env_path"
    done
  fi
}
