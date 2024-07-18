print_success() {
  local message=$1
  printf "\e[32m%s\e[0m\n" "$message"
}

print_error() {
  local message=$1
  printf "\e[31m%s\e[0m\n" "$message" >&2
}

STDERR_FILE=$(mktemp)

trap teardown EXIT
teardown() {
  rm -rf /tmp/local_sherpa_diagnose
  rm -rf "$STDERR_FILE"
}

check_enabled() {
  if [ "$SHERPA_ENABLED" = true ]; then
    print_success "[OK] Enabled"
  else
    print_error "[NOT OK] Enabled"
    echo "Sherpa is disabled! Enable it with 'sherpa on'." >&2
    exit 1
  fi
}

check_checksum_function_exists() {
  if type sha256sum > /dev/null 2>&1; then
    print_success "[OK] sha256sum utility"
  else
    print_error "[NOT OK] sha256sum utility"
    echo "Make sure the sha256sum utility is available in your system." >&2
    exit 1
  fi
}

setup_test_env() {
  rm -rf /tmp/local_sherpa_diagnose
  mkdir -p /tmp/local_sherpa_diagnose
  export SHERPA_CHECKSUM_DIR="/tmp/local_sherpa_diagnose/local_sherpa_checksums"

  cd /tmp/local_sherpa_diagnose
  echo "alias test_alias_1='echo works'" > "$SHERPA_ENV_FILENAME"
}

test_trusting_the_current_directory() {
  if sherpa trust > /dev/null 2> "$STDERR_FILE"; then
    print_success "[OK] Trusting the current directory"
  else
    print_error "[NOT OK] Trusting the current directory"
    cat "$STDERR_FILE" >&2
    rm "$STDERR_FILE"
    exit 1
  fi
}

test_loading_the_local_env() {
  if [ "$(test_alias_1 2> /dev/null)" = "works" ]; then
    print_success "[OK] Loading the local environment"
  else
    print_error "[NOT OK] Loading the local environment"
    exit 1
  fi
}

print_all_ok() {
  echo ""
  print_success "All systems are up and operational."
}
