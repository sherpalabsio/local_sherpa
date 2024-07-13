# Init the app

source tests/support/init_tools.sh
source ../lib/init.sh

# shellcheck disable=SC2034
SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"
SHERPA_CONFIG_DIR="$SHERPA_PATH/tests/playground/local_sherpa_config"
export SHERPA_LOG_LEVEL='no talk' # debug, info, no talking

if [ -z "$ZSH_VERSION" ]; then
  # Emulate the behavior of `cd` in interactive Bash
  # For some reason the PROMPT_COMMAND is ignored in the tests even we are
  # running Bash in interactive mode
  cd() {
    builtin cd "$@"
    alert_sherpa_we_changed_dir
  }
fi

source ../support/init_tools.sh
