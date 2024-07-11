# Init the test related tools

cd tests

source support/assertions.sh

export TMP_TEST_DIR=$(mktemp -d)

trap _init_teardown EXIT
_init_teardown() {
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$SHERPA_PATH/tests/playground" > /dev/null
  # Remove untracked files and directories
  git clean -df "$SHERPA_PATH/tests/playground" > /dev/null

  rm -rf "$TMP_TEST_DIR"
}
