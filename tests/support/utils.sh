_echo_in_red() {
  echo -e "\033[31m$1\033[0m"
}

_echo_in_green() {
  echo -e "\033[32m$1\033[0m"
}

_echo_in_yellow() {
  echo -e "\033[33m$1\033[0m"
}

_echo_in_magenta() {
  echo -e "\033[35m$1\033[0m"
}

_print_in_red() {
  printf "\033[31m%s\033[0m" "$1"
}

_skip_for_zsh() {
  [ -n "$ZSH_VERSION" ] && echo "Skip: Zsh" && exit 0
}
