cd tests

source ../lib/init.sh
source support/assertions.sh

# shellcheck disable=SC2034
SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"
export SHERPA_LOG_LEVEL='no talk' # debug, info, no talking

if [ -z "$ZSH_VERSION" ]; then
  # Emulate the behavior of `cd` in interactive bash
  # For some reason the PROMPT_COMMAND is ignored in the tests even we are
  # running bash in interactive mode
  cd() {
    builtin cd "$@"
    alert_sherpa_we_changed_dir
  }
fi

trap teardown EXIT
teardown() {
  # Clean up the tests/playground directory
  # Rollback changes to tracked files
  git checkout -- "$SHERPA_PATH/tests/playground" > /dev/null
  # Remove untracked files and directories
  git clean -df "$SHERPA_PATH/tests/playground" > /dev/null
}
