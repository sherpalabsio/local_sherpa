print_success() {
  local message=$1
  printf "\e[32m%s\e[0m\n" "$message"
}

print_error() {
  local message=$1
  printf "\e[31m%s\e[0m\n" "$message" >&2
}
