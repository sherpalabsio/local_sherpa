# Usage: source tests/support/assertions.sh
# - Exact match:
#   is "$string_1" "$string_2" "explain the assertion"
#   $string_1 and $string_2 are exactly the same
#
# - Partial match:
#   like "$string_1" "$string_2" "explain the assertion"
#   $string_1 includes $string_2

# Exact match
is(){
  local -r actual="$1"
  local -r expected="$2"
  local -r message="$3"

  if [ "$1" != "$2" ]; then
    _print_in_red "not ok"
    [ -n "$message" ] && printf " - $message"
    printf "\n\n"

    printf "  failure: not an exact match\n\n"

    echo "  expected: $expected"
    echo "       got: $actual"

    printf "\n$(_failed_assertion_path_with_line_number)\n"

    exit 1
  else
    printf "ok"
    [ -n "$message" ] && printf " - $message"
    printf "\n"
  fi
}

# Partial match
like(){
  local -r actual="$1"
  local -r expected_pattern="$2"
  local -r message="$3"

  if [[ ! "$actual" =~ $expected_pattern ]]; then
    _print_in_red "not ok"
    [ -n "$message" ] && printf " - $message"
    printf "\n\n"

    printf "   failure: not a partial match\n\n"

    echo "   pattern: $expected_pattern"
    echo "       got: $actual"

    printf "\n$(_failed_assertion_path_with_line_number)\n"

    exit 1
  else
    printf "ok"
    [ -n "$message" ] && printf " - $message"
    printf "\n"
  fi
}

_failed_assertion_path_with_line_number(){
  if [ -n "$ZSH_VERSION" ]; then
    echo "${funcfiletrace[2]}"
  else
    echo "${BASH_SOURCE[2]}:${BASH_LINENO[1]}"
  fi
}

_print_in_red(){
  printf "\033[31m$1\033[0m"
}
