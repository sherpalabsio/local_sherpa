__SHERPA_COMMAND_PALETTE_TMP_DIR="/tmp/local_sherpa_command_palette"

_sherpa_command_palette() {
  __sherpa_command_palette__check_preconditions || return 0

  local selected
  selected=$(
    __sherpa_command_palette__load_env_items |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --preview "cat $__SHERPA_COMMAND_PALETTE_TMP_DIR/{}" \
          --preview-window wrap \
          --border-label=" Sherpa Command Palette "
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

__sherpa_command_palette__check_preconditions() {
  __safe_echo() {
    # Called from a Zsh keybinding?
    if [ -n "$ZSH_VERSION" ] && zle; then
      zle reset-prompt
      echo
    fi

    echo "Sherpa: $1"
  }

  if [ ${#SHERPA_LOADED_ENV_DIRS[@]} -eq 0 ]; then
    __safe_echo "There is no loaded env"
    return 1
  fi

  # Warn the user if fzf is not installed
  if ! command -v fzf > /dev/null; then
    __safe_echo "Please install fzf to use this feature"
    return 1
  fi

  local -r fzf_version=$(fzf --version | cut -d' ' -f1)
  local -r fzf_major_version=$(echo "$fzf_version" | cut -d. -f1)
  local -r fzf_minor_version=$(echo "$fzf_version" | cut -d. -f2)

  # Warn the user if fzf version is not supported
  if [[ "$fzf_major_version" -eq 0 && "$fzf_minor_version" -lt 42 ]]; then
    __safe_echo "The minimum fzf version is 0.42.0. Please upgrade it to use this feature."
    return 1
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

  [ ${#env_items[@]} -eq 0 ] && return

  # Filter and sort
  printf "%s\n" "${env_items[@]}" | sort | uniq
}

__sherpa_command_palette__get_variable_names() {
  local var_name value

  # shellcheck disable=SC2116
  for var_name in $(echo "${SHERPA_STATUS_INFO__VARS[@]}"); do
    eval "value=\$$var_name"
    echo "$value" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/\$$var_name"
    echo "\$$var_name"
  done
}

__sherpa_command_palette__get_alias_names() {
  local alias_name alias_definition

  # shellcheck disable=SC2116
  for alias_name in $(echo "${SHERPA_STATUS_INFO__ALIASES[@]}"); do
    alias "$alias_name" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name"
    alias_definition=$(cat "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name")
    alias_definition=${alias_definition#*=\'} # Remove everything up to and including ='
    alias_definition=${alias_definition%?} # Remove the last character
    echo "$alias_definition" | sed "s/\\\\''//g" | sed "s/\\\\$//g" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$alias_name"
    echo "$alias_name"
  done
}

__sherpa_command_palette__get_function_names() {
  local function_name

  # shellcheck disable=SC2116
  for function_name in $(echo "${SHERPA_STATUS_INFO__FUNCTIONS[@]}"); do
    declare -f "$function_name" > "$__SHERPA_COMMAND_PALETTE_TMP_DIR/$function_name"
    echo "$function_name"
  done
}
