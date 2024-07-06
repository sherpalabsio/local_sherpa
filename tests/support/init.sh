cd tests

source ../lib/init.sh
source support/assertions.sh

SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"
export SHERPA_LOG_LEVEL='no talk' # debug, info, no talking

if [ ! -n "$ZSH_VERSION" ]; then
  # Emulate the behavior of `cd` in interactive bash
  cd() {
    builtin cd "$@"
    alert_sherpa_we_changed_dir
  }
fi

trap teardown EXIT
teardown() {
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$SHERPA_PATH/tests/playground"
  # Remove untracked files and directories
  git clean -df "$SHERPA_PATH/tests/playground"
}
