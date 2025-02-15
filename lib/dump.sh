_sherpa_dump_current_env() {
  _sherpa_dump_current_env__sanitize > "$SHERPA_ENV_FILENAME.example"
}

_sherpa_dump_current_env__sanitize() {
  # shellcheck disable=SC2002
  cat "$SHERPA_ENV_FILENAME" | while IFS= read -r line; do
    # Skip if line ends with "# keep"
    if [[ $line =~ [[:space:]]*#[[:space:]]*keep[[:space:]]*$ ]]; then
      echo "$line"
      continue
    fi

    echo "$line" |
      sed '/^export [^[:space:]]*=/s/=.*/=/' |
      sed '/^[^[:space:]]*=/s/=.*/=/'
  done
}
