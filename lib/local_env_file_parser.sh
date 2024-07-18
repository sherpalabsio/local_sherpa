# It returns a list that contains variable, function and alias names
_sherpa_parse_local_env_file() {
  fetch_variable_names() {
    local -r filter_pattern='^[[:space:]]*export[[:space:]]+[[:alnum:]_]+'
    local variable_names
    # Cleanup:
    # export var_1 -> var_1
    variable_names=$(grep -oE "$filter_pattern" "$SHERPA_ENV_FILENAME" | awk '{print $2}')

    if [ -n "$variable_names" ]; then
      echo "$variable_names"
    fi
  }

  fetch_aliase_names() {
    local -r filter_pattern='^[[:space:]]*alias[[:space:]]'
    local alias_names
    # Cleanup:
    # alias alias_1=... -> alias_1
    alias_names=$(grep -E "$filter_pattern" "$SHERPA_ENV_FILENAME" | awk -F'[ =]' '{print $2}')

    if [ -n "$alias_names" ]; then
      echo "$alias_names"
    fi
  }

  fetch_function_names() {
    local -r filter_pattern='^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)'
    local function_names
    # Cleanup:
    # function_1() -> function_1
    # function function_2() -> function_2() -> function_2
    function_names=$(grep -oE "$filter_pattern" "$SHERPA_ENV_FILENAME" | \
                    sed 's/function //' | \
                    sed 's/()//')

    if [ -n "$function_names" ]; then
      echo "$function_names"
    fi
  }

  fetch_variable_names
  fetch_aliase_names
  fetch_function_names
}
