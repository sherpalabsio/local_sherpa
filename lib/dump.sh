_sherpa_dump_current_env() {
  _sherpa_dump_current_env__sanitize > "$SHERPA_ENV_FILENAME.example"
}

_sherpa_dump_current_env__sanitize() {
  # shellcheck disable=SC2002
  cat "$SHERPA_ENV_FILENAME" |
    sed '/^export [^[:space:]]*=/s/=.*/=/' |
    sed '/^[^[:space:]]*=/s/=.*/=/'
}
