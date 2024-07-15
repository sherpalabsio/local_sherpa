_local_sherpa__log_level_in_number() {
  case "$SHERPA_LOG_LEVEL" in
    debug) echo 0 ;;
    info) echo 1 ;;
    *) echo 2 ;;
  esac
}

_local_sherpa_log_debug() {
  [ "$(_local_sherpa__log_level_in_number)" -le 0 ] && echo "Sherpa debug: $1"
}

_local_sherpa_log_info() {
  [ "$(_local_sherpa__log_level_in_number)" -le 1 ] && echo "Sherpa: $1"
}

_local_sherpa_log_error() {
  echo "Sherpa: $1" >&2
}

_local_sherpa_log() {
  echo "$1"
}
