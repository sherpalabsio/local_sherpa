_sherpa_print_status() {
  echo "================ Current folder status ==============="
  __sherpa_status_print_env_file_info
  __sherpa_status_print_loaded_envs

  echo
  echo "======================= Config ======================="
  echo "Enabled: $SHERPA_ENABLED"
  echo "Log level: $(_sherpa_get_log_level_in_text) ($SHERPA_LOG_LEVEL)"
  echo "Env file name: $SHERPA_ENV_FILENAME"
  if [ "$SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING" = true ]; then
    echo "Dynamic env file parsing: enabled"
  else
    echo "Dynamic env file parsing: disabled"
  fi

  echo
  echo "==================== Trusted dirs ===================="
  __sherpa_status_print_trusted_dirs

  echo
  echo "===================== Debug info ====================="
  echo "Config dir:   $SHERPA_CONFIG_DIR"
  echo "Checksum dir: $SHERPA_CHECKSUM_DIR"
}

__sherpa_status_print_env_file_info() {
  if [ ! -f "$SHERPA_ENV_FILENAME" ]; then
    echo "Env file: [none]"
    return
  fi

  _sherpa_verify_trust > /dev/null
  case "$?" in
     0) echo "Env file trusted: yes";;
    10) echo "Env file trusted: no";;
    20) echo "Env file trusted: no (file has changed)";;
     *) echo "Env file trusted: unknown";;
  esac
}

__sherpa_status_print_loaded_envs() {
  if [ ${#SHERPA_LOADED_ENV_DIRS[@]} -eq 0 ]; then
    echo "Loaded envs: [none]"
  else
    echo "Loaded envs:"

    # We store the paths in reverse order, so we need to iterate in reverse
    local last_index first_index

    # Zsh array indexing starts at 1 :facepalm:
    if [ -n "$ZSH_VERSION" ]; then
      last_index=$(( ${#SHERPA_LOADED_ENV_DIRS[@]} ))
      first_index=1
    else
      last_index=$(( ${#SHERPA_LOADED_ENV_DIRS[@]} - 1 ))
      first_index=0
    fi

    for ((i=last_index; i>=first_index; i--)); do
      echo "- ${SHERPA_LOADED_ENV_DIRS[i]}"
    done
  fi
}

__sherpa_status_print_trusted_dirs() {
  for checksum_file in "$SHERPA_CHECKSUM_DIR"/*; do
    trusted_dir=$(cut -d "|" -f 2 "$checksum_file")

    if _sherpa_verify_trust "$trusted_dir" > /dev/null 2>&1; then
      echo "$trusted_dir"
    fi
  done
}
