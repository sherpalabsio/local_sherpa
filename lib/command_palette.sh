__SHERPA_COMMAND_PALETTE_TMP_DIR="/tmp/local_sherpa_command_palette"

_sherpa_command_palette() {
  local selected
  selected=$(
    __sherpa_command_palette__load_env_items |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --preview 'cat /tmp/local_sherpa_command_palette/{}' \
          --preview-window wrap
  )

  rm -rf "$__SHERPA_COMMAND_PALETTE_TMP_DIR"

  [ -z "$selected" ] && return

  if [ -n "$ZSH_VERSION" ]; then
    # Is it called through a keybinding or directly?
    if zle; then
      LBUFFER="${LBUFFER}${selected}"
      zle reset-prompt
    else
      print -z "$selected"
    fi
  else
    # Is it called through a keybinding or directly?
    if [[ "$READLINE_POINT" = 0 ]]; then
      READLINE_LINE="$selected"
      READLINE_POINT=${#READLINE_LINE}
    else
      read -re -p "${PS1@P}" -i "$selected" cmd
      eval "$cmd"
    fi
  fi
}

__sherpa_command_palette__load_env_items() {
  rm -rf "$__SHERPA_COMMAND_PALETTE_TMP_DIR"
  mkdir -p "$__SHERPA_COMMAND_PALETTE_TMP_DIR"

  local env_items
  # shellcheck disable=SC2207
  env_items=(
    $(__sherpa_command_palette__get_variable_names)
    $(__sherpa_command_palette__get_alias_names)
    $(__sherpa_command_palette__get_function_names)
  )

  # Filter and sort
  printf "%s\n" "${env_items[@]}" | sort | uniq
}

__sherpa_command_palette__get_variable_names() {
  local var_names var_name value

  if [ -n "$ZSH_VERSION" ]; then
    IFS=" " read -r -A var_names <<< "${SHERPA_STATUS_INFO__VARS[@]}"
  else
    IFS=" " read -r -a var_names <<< "${SHERPA_STATUS_INFO__VARS[@]}"
  fi

  for var_name in "${var_names[@]}"; do
    eval "value=\$$var_name"
    echo "$value" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/\$$var_name"
    echo "\$$var_name"
  done
}

__sherpa_command_palette__get_alias_names() {
  local alias_names alias_name alias_definition

  if [ -n "$ZSH_VERSION" ]; then
    IFS=" " read -r -A alias_names <<< "${SHERPA_STATUS_INFO__ALIASES[@]}"
  else
    IFS=" " read -r -a alias_names <<< "${SHERPA_STATUS_INFO__ALIASES[@]}"
  fi

  for alias_name in "${alias_names[@]}"; do
    alias "$alias_name" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name"
    alias_definition=$(cat "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name")
    alias_definition=${alias_definition#*=\'} # Remove everything up to and including ='
    alias_definition=${alias_definition%?} # Remove the last character
    echo "$alias_definition" | sed "s/\\\\''//g" | sed "s/\\\\$//g" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name"
    echo "$alias_name"
  done
}

__sherpa_command_palette__get_function_names() {
  local function_names function_name

  if [ -n "$ZSH_VERSION" ]; then
    IFS=" " read -r -A function_names <<< "${SHERPA_STATUS_INFO__FUNCTIONS[@]}"
  else
    IFS=" " read -r -a function_names <<< "${SHERPA_STATUS_INFO__FUNCTIONS[@]}"
  fi

  for function_name in "${function_names[@]}"; do
    declare -f "$function_name" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$function_name"
    echo "$function_name"
  done
}
