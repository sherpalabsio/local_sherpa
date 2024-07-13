load_global_config() {
  local variable_name="$1"
  local default_value="$2"
  local config_file="$SHERPA_CONFIG_DIR/$variable_name"

  # shellcheck disable=SC2155
  local current_global_value=$(eval "echo \"\$$variable_name\"")

  # Check if the env var is set
  if [ -z "$current_global_value" ]; then
    # Check if the config file exists
    if [ -f "$config_file" ]; then
      export "$variable_name=$(cat "$config_file")"
    else
      export "$variable_name=$default_value"
    fi
  fi
}

save_global_config() {
  local variable_name="$1"
  local value="$2"

  # Check if the config dir exists
  if [ ! -d "$SHERPA_CONFIG_DIR" ]; then
    mkdir -p "$SHERPA_CONFIG_DIR"
  fi

  echo "$value" > "$SHERPA_CONFIG_DIR/$variable_name"

  # Set the env var
  eval "export $variable_name=\"$value\""
}
