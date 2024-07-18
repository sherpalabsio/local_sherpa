_sherpa__log_level_in_number() {
  case "$SHERPA_LOG_LEVEL" in
    debug) echo 0 ;;
    info) echo 1 ;;
    *) echo 2 ;;
  esac
}

_sherpa_log_debug() {
  [ "$(_sherpa__log_level_in_number)" -le 0 ] && echo "Sherpa debug: $1"
}

_sherpa_log_info() {
  [ "$(_sherpa__log_level_in_number)" -le 1 ] && echo "Sherpa: $1"
}

_sherpa_log_error() {
  echo "Sherpa: $1" >&2
  [ -z "$2" ] && return
  echo "        $2" >&2
}

_sherpa_log() {
  echo "$1"
}
