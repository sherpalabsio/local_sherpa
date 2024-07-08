# Usage: source tests/support/assertions.sh
#
# - Exact match:
#   is "$string_1" "$string_2" "explain the assertion"
#   $string_1 and $string_2 are exactly the same
#
# - Partial match:
#   like "$string_1" "$string_2" "explain the assertion"
#   $string_1 includes $string_2
#
# - Undefined check:
#   is_undefined "thing" "explain the assertion"
#   thing can be a variable, a function or an alias

# Exact match
is(){
  local -r actual="$1"
  local -r expected="$2"
  local -r message="$3"

  if [ "$1" != "$2" ]; then
    _print_in_red "not ok"
    [ -n "$message" ] && printf " - %s" "$message"
    printf "\n\n"

    printf "  failure: not an exact match\n\n"

    echo "  expected: $expected"
    echo "       got: $actual"

    echo ""
    _failed_assertion_path_with_line_number >&2

    exit 1
  else
    _print_ok "$message"
  fi
}

# Partial match
like(){
  local -r actual="$1"
  local -r expected_pattern="$2"
  local -r message="$3"

  if [[ ! "$actual" =~ $expected_pattern ]]; then
    _print_in_red "not ok"
    [ -n "$message" ] && printf " - %s" "$message"
    printf "\n\n"

    printf "   failure: not a partial match\n\n"

    printf "   pattern: %s\n" "$expected_pattern"
    printf "       got: %s\n" "$actual"

    _failed_assertion_path_with_line_number >&2

    exit 1
  else
    _print_ok "$message"
  fi
}

# Check if a variable, a function or an alias is undefined
is_undefined(){
  local -r item="$1"
  local -r message="$2"

  if _is_defined "$item"; then
    _print_in_red "not ok"
    [ -n "$message" ] && printf " - %s" "$message"
    printf "\n\n"

    printf "  failure: %s is defined when it should not be" "$item"

    echo ""
    _failed_assertion_path_with_line_number >&2

    exit 1
  else
    _print_ok "$message"
  fi
}

# == General Utils ==
_is_defined() {
  local name_of_thing="$1"

  # Is it a defined variable?
  if declare -p "$name_of_thing" > /dev/null 2>&1; then
    return 0
  fi

  # Is it a defined function or an alias?
  type "$name_of_thing" > /dev/null 2>&1
  return $?
}

_failed_assertion_path_with_line_number(){
  if [ -n "$ZSH_VERSION" ]; then
    # shellcheck disable=SC2154
    echo "${funcfiletrace[2]}"
  else
    echo "${BASH_SOURCE[2]}:${BASH_LINENO[1]}"
  fi
}

# == Print Utils ==
_print_ok(){
  local -r message="$1"

  printf "ok"
  [ -n "$message" ] && printf " - %s" "$message"
  printf "\n"
}

_print_in_red(){
  printf "\033[31m%s\033[0m" "$1"
}
