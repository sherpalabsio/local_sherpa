_log_level_in_number() {
  case "$SHERPA_LOG_LEVEL" in
    debug) echo 0 ;;
    info) echo 1 ;;
    *) echo 2 ;;
  esac
}

log_debug() {
  [ "$(_log_level_in_number)" -le 0 ] && echo "$1"
}

log_info() {
  [ "$(_log_level_in_number)" -le 1 ] && echo "$1"
}

log() {
  echo "$1"
}
