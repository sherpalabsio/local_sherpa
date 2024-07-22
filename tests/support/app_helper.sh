# Init the app

source tests/support/test_helper.sh
# We load the app later so it won't load the env file from the project root
source "$SHERPA_DIR/lib/init.sh"

# shellcheck disable=SC2034
SHERPA_CHECKSUM_DIR="$TEST_DIR/playground/local_sherpa_checksums"
SHERPA_CONFIG_DIR="$TEST_DIR/playground/local_sherpa_config"
SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_SILENT"

if [ -z "$ZSH_VERSION" ]; then
  # Emulate the behavior of `cd` in interactive Bash
  # For some reason the PROMPT_COMMAND is ignored in the tests even we are
  # running Bash in interactive mode
  cd() {
    builtin cd "$@"
    _sherpa_alert_sherpa_we_changed_dir
  }
fi
