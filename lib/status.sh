_sherpa_print_status() {
  echo "Enabled: $SHERPA_ENABLED"
  echo "Log level: $SHERPA_LOG_LEVEL"
  echo "Local env file: $SHERPA_ENV_FILENAME"

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
