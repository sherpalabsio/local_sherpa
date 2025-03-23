_sherpa_command_palette() {
  local -r temp_dir="/tmp/local_sherpa_command_palette"

  rm -rf "$temp_dir"
  mkdir -p "$temp_dir"

  # Process variables
  local var_names var_name value
  # shellcheck disable=SC2207
  var_names=($(__sherpa_command_palette__load_local_variables))
  for var_name in "${var_names[@]}"; do
    eval "value=\$$var_name"
    echo "$value" > "$temp_dir/\$$var_name"
  done

  # Process functions
  local function_names function_name
  # shellcheck disable=SC2207
  function_names=($(__sherpa_command_palette__load_local_functions))
  for function_name in "${function_names[@]}"; do
    declare -f "$function_name" > "$temp_dir/$function_name"
  done

  # Process aliases
  local alias_names alias_name alias_definition
  # shellcheck disable=SC2207
  alias_names=($(__sherpa_command_palette__load_local_aliases))

  for alias_name in "${alias_names[@]}"; do
    alias "$alias_name" > "$temp_dir/$alias_name"

    alias_definition=$(cat "$temp_dir/$alias_name")
    alias_definition=${alias_definition#*=\'} # Remove everything up to and including ='
    alias_definition=${alias_definition%?} # Remove the last character

    echo "$alias_definition" | sed "s/\\\\''//g" | sed "s/\\\\$//g" > "$temp_dir/$alias_name"
  done

  local env_items

  # shellcheck disable=SC2207
  env_items=(
    $(__sherpa_command_palette__load_local_variables | sed 's/\([^ ]*\)/\$\1/g')
    $(__sherpa_command_palette__load_local_aliases)
    $(__sherpa_command_palette__load_local_functions)
  )

  # Filter and sort
  # shellcheck disable=SC2207
  env_items=(
    $(
      printf "%s\n" "${env_items[@]}" |
        sort |
        uniq
    )
  )

  local selected
  selected=$(
    printf "%s\n" "${env_items[@]}" |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=19%,11% \
          --padding=1 \
          --cycle \
          --preview 'cat /tmp/local_sherpa_command_palette/{}' \
          --preview-window wrap
  )

  rm -rf "$temp_dir"

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

__sherpa_command_palette__load_local_variables() {
  if [ -n "$ZSH_VERSION" ]; then
    echo "$SHERPA_STATUS_INFO__VARS"
  else
    echo "${SHERPA_STATUS_INFO__VARS[@]}"
  fi
}

__sherpa_command_palette__load_local_aliases() {
  if [ -n "$ZSH_VERSION" ]; then
    echo "$SHERPA_STATUS_INFO__ALIASES"
  else
    echo "${SHERPA_STATUS_INFO__ALIASES[@]}"
  fi
}

__sherpa_command_palette__load_local_functions() {
  if [ -n "$ZSH_VERSION" ]; then
    echo "$SHERPA_STATUS_INFO__FUNCTIONS"
  else
    echo "${SHERPA_STATUS_INFO__FUNCTIONS[@]}"
  fi
}
