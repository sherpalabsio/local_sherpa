# Init the test related tools

source tests/support/assertions.sh
[[ -z $SHERPA_LOG_LEVEL_SILENT ]] && source lib/logger.sh

cd tests/playground

# shellcheck disable=SC2155
export TMP_TEST_DIR=$(mktemp -d)

trap _init_teardown EXIT
_init_teardown() {
  SHERPA_LOG_LEVEL="${SHERPA_LOG_LEVEL_SILENT}"

  cd "$SHERPA_PATH"
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$SHERPA_PATH/tests/playground" > /dev/null
  # Remove untracked files and directories
  git clean -df "$SHERPA_PATH/tests/playground" > /dev/null

  rm -rf "$TMP_TEST_DIR"
}
