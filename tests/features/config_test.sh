source tests/support/test_helper.sh

SHERPA_CONFIG_DIR="$TEST_DIR/playground/local_sherpa_config"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                              Setting the log Level
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# xxxx When the log level is not set anywhere
# ++++ It sets the log level to the default value

unset SHERPA_LOG_LEVEL
source "$SHERPA_DIR/lib/init.sh" > /dev/null

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_INFO" "The log level is set to the default value"


# ==============================================================================
# xxxx When the log level is set via the env var
# ++++ It does not change the log level

SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_SILENT"

source "$SHERPA_DIR/lib/init.sh"

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT" "The log level is set based on the env var"


# ==============================================================================
# xxxx When the log level is set via the config file
# ++++ It sets the log level based on the config file

sherpa talk no more > /dev/null
unset SHERPA_LOG_LEVEL

source "$SHERPA_DIR/lib/init.sh"

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT" "The log level is set based on the config file"


# ==============================================================================
# xxxx When the log level is set via the config file but the env var is set as well
# ++++ It sets the log level based on the env var

sherpa talk no more > /dev/null
SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_DEBUG"

source "$SHERPA_DIR/lib/init.sh" > /dev/null

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_DEBUG" "The log level is set based on the env var"
