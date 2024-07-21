# Init the test related tools

source tests/support/assertions.sh
[[ -z $SHERPA_LOG_LEVEL_SILENT ]] && source lib/logger.sh

cd tests/playground

# shellcheck disable=SC2155
readonly TESTS_DIR=$(cd .. && pwd)

# shellcheck disable=SC2155
export TMP_TEST_DIR=$(mktemp -d)
# shellcheck disable=SC2155
export TMP_TEST_FILE=$(mktemp)

trap _init_teardown EXIT
_init_teardown() {
  SHERPA_LOG_LEVEL="${SHERPA_LOG_LEVEL_SILENT}"

  cd "$TESTS_DIR"
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$TESTS_DIR/playground" > /dev/null
  # Remove untracked files and directories
  git clean -df "$TESTS_DIR/playground" > /dev/null

  rm -rf "$TMP_TEST_DIR"
  rm -f "$TMP_TEST_FILE"
}

stub_local_env_file() {
  export SHERPA_ENV_FILENAME="$TMP_TEST_FILE"
  echo "$1" > "$SHERPA_ENV_FILENAME"
}
