_sherpa_command_palette() {
  local commands selected_command

  # shellcheck disable=SC2207
  commands=(
    $(__sherpa_command_palette__load_local_aliases)
    $(__sherpa_command_palette__load_local_functions)
  )

  # Filter and sort the commands
  # shellcheck disable=SC2207
  commands=(
    $(
      printf "%s\n" "${commands[@]}" |
        awk 'length >= 2' | # Remove short commands
        sort
    )
  )

  selected_command=$(
    printf "%s\n" "${commands[@]}" |
      fzf --layout=reverse \
          --border \
          --info=inline \
          --margin=8,20 \
          --padding=1 \
          --cycle
  )

  if [ -n "$selected_command" ]; then
    echo "Running: $selected_command"
    eval "$selected_command"
  fi
}

__sherpa_command_palette__load_local_aliases() {
  unalias -a

  # shellcheck disable=SC1090
  source "$SHERPA_ENV_FILENAME" &> /dev/null

  compgen -a
}

__sherpa_command_palette__load_local_functions() {
  local -r filter_pattern="^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)"

  # Cleanup:
  # "function_1()" -> "function_1"
  # "function function_2()" -> "function_2()" -> "function_2"
  grep -oE "$filter_pattern" "$SHERPA_ENV_FILENAME" |
    sed "s/function //" |
    sed "s/()//"
}
