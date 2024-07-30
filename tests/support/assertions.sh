# This file contains the assertion functions for the test suite.
#
# == Usage:

# assert_equal():
#   - Compares two values
#   - Parameters:
#       - actual: The actual value to compare.
#       - expected: The expected value to compare against.
#       - message: An optional message to display along with the result.
#   - Example usage: assert_equal "$actual" "$expected" "Values should be equal"

# assert_equal_compact():
#   - The same as assert_equal() but it removes all tabs, spaces and new lines before
#     comparing the values

# assert_contain():
#   - Checks if the actual value contains the expected pattern
#   - Parameters:
#       - actual: The actual value to check.
#       - expected_pattern: The pattern to match against.
#       - message: An optional message to display along with the result.
#   - Example usage: assert_contain "$actual" "$expected_pattern" "Value should match the pattern"

# assert_undefined():
#   - Checks if a variable, a function or an alias is undefined
#   - Parameters:
#       - item: The name of the variable, function or alias to check.
#       - message: An optional message to display along with the result.
#   - Example usage: assert_undefined "some_variable" "Variable should be undefined"


# Exact match
assert_equal(){
  local -r actual="$1"
  local -r expected="$2"
  local -r message="$3"

  if [ "$1" = "$2" ]; then
    __print_ok "$message"
    return
  fi

  __print_not_ok "$message"
  __print_comparsion "$actual" "$expected"
  __report_failure

  exit 1
}

# Exact match buth without tabs, spaces and new lines
assert_equal_compact(){
  local -r actual="$1"
  local -r expected="$2"
  local -r message="$3"

  local -r actual_trimmed=$(echo "$actual" | tr -d '[:space:]')
  local -r expected_trimmed=$(echo "$expected" | tr -d '[:space:]')

  assert_equal "$actual_trimmed" "$expected_trimmed" "$message"
}

# Partial match
assert_contain(){
  local -r actual="$1"
  local -r expected_pattern="$2"
  local -r message="$3"

  if [[ "$actual" =~ $expected_pattern ]]; then
    __print_ok "$message"
    return
  fi

  __print_not_ok "$message"
  __print_comparsion "$actual" "$expected_pattern" "Not a partial match!" "~"
  __report_failure

  exit 1
}

# Check if a variable, a function or an alias is undefined
assert_undefined(){
  local -r item="$1"
  local -r message="$2"

  if ! __is_defined "$item"; then
    __print_ok "$message"
    return
  fi

  __print_not_ok "$message"
  echo "  Failure: $item is defined when it should not be"
  __report_failure

  exit 1
}

# == General Utils ==
__is_defined() {
  local -r name_of_thing="$1"

  # Is it a defined variable?
  if declare -p "$name_of_thing" > /dev/null 2>&1; then
    return 0
  fi

  # Is it a defined function or an alias?
  type "$name_of_thing" > /dev/null 2>&1
  return $?
}

__report_failure(){
  if [ -n "$ZSH_VERSION" ]; then
    # shellcheck disable=SC2154
    echo "${funcfiletrace[-1]}" >&2
  else
    echo "${BASH_SOURCE[-1]}:${BASH_LINENO[-2]}" >&2
  fi
}

# == Print Utils ==
__print_ok(){
  local -r message="$1"

  printf "ok"
  [ -n "$message" ] && printf " - %s" "$message"
  printf "\n"
}

__print_not_ok(){
  local -r message="$1"

  _print_in_red "not ok"
  [ -n "$message" ] && printf " - %s" "$message"
  printf "\n\n"
}

__print_comparsion() {
  local -r actual="$1"
  local -r expected="$2"
  local -r message="$3"
  local -r expected_prefix="$4"

  if [ -n "$expected_prefix" ]; then
    local -r expected_copy=" ${expected_prefix}expected"
  else
    local -r expected_copy="  expected"
  fi

  [ -n "$message" ] && echo -e "$message\n"
  printf "$expected_copy: %s\n" "$(__add_ledt_padding_after_first_line "$expected")"
  printf "       got: %s\n" "$(__add_ledt_padding_after_first_line "$actual")"
  echo
}

# Add extra space to the left of each line after the first one
__add_ledt_padding_after_first_line(){
  local -r content="$1"
  local -r left_padding="            "
  local first_line=true

  while IFS= read -r line; do
    if $first_line; then
      # Print the first line as it is
      echo "$line"
      first_line=false
    else
      # Add left padding to the rest
      echo "${left_padding}${line}"
    fi
  done <<< "$content"
}
