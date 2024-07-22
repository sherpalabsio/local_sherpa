# Init the test related tools

source tests/support/assertions.sh
[[ -z $SHERPA_LOG_LEVEL_SILENT ]] && source lib/logger.sh

cd tests/playground

# shellcheck disable=SC2155
readonly TESTS_DIR=$(cd .. && pwd)

# shellcheck disable=SC2155
export TMP_TEST_DIR=$(mktemp -d)

trap _init_teardown EXIT
_init_teardown() {
  SHERPA_LOG_LEVEL="${SHERPA_LOG_LEVEL_SILENT}"

  cd "$TESTS_DIR"
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$TESTS_DIR/playground" > /dev/null
  # Remove untracked files and directories
  git clean -df "$TESTS_DIR/playground" > /dev/null

  rm -r "$TMP_TEST_DIR"
  rm -f "$TMP_TEST_FILE"
}


stub_env_file() {
  # shellcheck disable=SC2155
  readonly TMP_TEST_FILE=$(mktemp)
  export TMP_TEST_FILE
  export SHERPA_ENV_FILENAME="$TMP_TEST_FILE"
}

override_env_file() {
  if [ -n "$1" ]; then
    echo "$1" > "$SHERPA_ENV_FILENAME"
  else
    cat > "$SHERPA_ENV_FILENAME"
  fi
}
