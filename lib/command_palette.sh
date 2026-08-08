__SHERPA_COMMAND_PALETTE_TMP_DIR="/tmp/local_sherpa_command_palette"
__SHERPA_COMMAND_PALETTE_COMMAND_LIST_FILE="$__SHERPA_COMMAND_PALETTE_TMP_DIR/.commands"
__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE="$__SHERPA_COMMAND_PALETTE_TMP_DIR/.variables"

_sherpa_command_palette() {
  __sherpa_command_palette__check_preconditions || return 0

  __sherpa_command_palette__load_env_items

  # Sets __SHERPA_COMMAND_PALETTE_SELECTED and __SHERPA_COMMAND_PALETTE_RUN_IT
  __sherpa_command_palette__select

  local -r selected="$__SHERPA_COMMAND_PALETTE_SELECTED"
  local -r run_it="$__SHERPA_COMMAND_PALETTE_RUN_IT"

  rm -rf "$__SHERPA_COMMAND_PALETTE_TMP_DIR"

  [ -z "$selected" ] && return

  if [ -n "$ZSH_VERSION" ]; then
    # Is it called through a keybinding or directly?
    if zle; then
      LBUFFER="${LBUFFER}${selected}"
      [ "$run_it" = true ] && zle accept-line
      zle reset-prompt
    else
      if [ "$run_it" = true ]; then
        eval "$selected"
      else
        print -z "$selected"
      fi
    fi
  else
    # Is it called through a keybinding or directly?
    if [[ "$READLINE_POINT" = 0 ]]; then
      READLINE_LINE="$selected"
      READLINE_POINT=${#READLINE_LINE}
      [ "$run_it" = true ] && __sherpa_command_palette__accept_readline_buffer
    else
      if [ "$run_it" = true ]; then
        eval "$selected"
      else
        read -re -p "${PS1@P}" -i "$selected" cmd
        eval "$cmd"
      fi
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

# Show the picker until the user selects an item or aborts.
# Tab switches between the command list and the variable list.
__sherpa_command_palette__select() {
  __SHERPA_COMMAND_PALETTE_SELECTED=""
  __SHERPA_COMMAND_PALETTE_RUN_IT=false

  # The fzf key that pastes the selected item and runs it immediately.
  # Configure your terminal to send this key sequence (^_) for Cmd + Enter.
  local -r run_key="${SHERPA_COMMAND_PALETTE_RUN_KEY:-ctrl-_}"

  local list_file="$__SHERPA_COMMAND_PALETTE_COMMAND_LIST_FILE"
  local border_label result key

  # There is nothing to show on the command list, start with the variables
  [ -s "$list_file" ] || list_file="$__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE"

  while true; do
    border_label=$(__sherpa_command_palette__border_label "$list_file")

    result=$(
      fzf --expect "tab,$run_key" \
          --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --preview "cat $__SHERPA_COMMAND_PALETTE_TMP_DIR/{}" \
          --preview-window wrap \
          --border-label "$border_label" \
          < "$list_file"
    )

    key=$(echo "$result" | head -1)

    if [ "$key" = tab ]; then
      list_file=$(__sherpa_command_palette__other_list_file "$list_file")
      continue
    fi

    [ "$key" = "$run_key" ] && __SHERPA_COMMAND_PALETTE_RUN_IT=true
    __SHERPA_COMMAND_PALETTE_SELECTED=$(echo "$result" | tail -n +2)
    return
  done
}

# Show which list is active and what Tab switches to
__sherpa_command_palette__border_label() {
  if [ "$1" = "$__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE" ]; then
    echo " Variables ┃ Tab: Commands "
  else
    echo " Commands ┃ Tab: Variables "
  fi
}

__sherpa_command_palette__other_list_file() {
  if [ "$1" = "$__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE" ]; then
    echo "$__SHERPA_COMMAND_PALETTE_COMMAND_LIST_FILE"
  else
    echo "$__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE"
  fi
}

# Make Readline run the line we placed into its buffer.
# We ask the terminal for a status report, Readline reads the answer from the
# input stream and runs the action we bound to it.
__sherpa_command_palette__accept_readline_buffer() {
  bind '"\e[0n": accept-line' 2> /dev/null
  printf '\e[5n'
}

# Collect the env items into two lists so fzf can be restarted with the other
# one when the user hits Tab
__sherpa_command_palette__load_env_items() {
  rm -rf "$__SHERPA_COMMAND_PALETTE_TMP_DIR"
  mkdir -p "$__SHERPA_COMMAND_PALETTE_TMP_DIR"

  local command_items variable_items
  # shellcheck disable=SC2207
  command_items=(
    $(__sherpa_command_palette__get_alias_names)
    $(__sherpa_command_palette__get_function_names)
  )
  # shellcheck disable=SC2207
  variable_items=(
    $(__sherpa_command_palette__get_variable_names)
  )

  __sherpa_command_palette__write_list_file \
    "$__SHERPA_COMMAND_PALETTE_COMMAND_LIST_FILE" "${command_items[@]}"
  __sherpa_command_palette__write_list_file \
    "$__SHERPA_COMMAND_PALETTE_VARIABLE_LIST_FILE" "${variable_items[@]}"
}

# Sort and deduplicate the given items into a list file
__sherpa_command_palette__write_list_file() {
  local -r list_file="$1"
  shift

  : > "$list_file"

  [ $# -eq 0 ] && return

  printf "%s\n" "$@" | sort | uniq > "$list_file"
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
