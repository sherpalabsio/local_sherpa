source tests/support/init_tools.sh

# shellcheck disable=SC2034
SHERPA_CONFIG_DIR="$TMP_TEST_DIR/tests/playground/local_sherpa_config"

# ==============================================================================
# ++++ Log Level ++++

# When the log level is not set anywhere
# It sets the log level to the default value
unset SHERPA_LOG_LEVEL
source ../../lib/init.sh > /dev/null

is "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_INFO" "The log level is set to the default value"


# When the log level is set via the env var
# It does not change the log level
SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_SILENT"

source ../../lib/init.sh

is "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT" "The log level is set based on the env var"


# When the log level is set via the config file
# It sets the log level based on the config file
sherpa talk no more > /dev/null
unset SHERPA_LOG_LEVEL

source ../../lib/init.sh

is "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT" "The log level is set based on the config file"


# When the log level is set via the config file but the env var is set as well
# It sets the log level based on the env var
sherpa talk no more > /dev/null
SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_DEBUG"

source ../../lib/init.sh > /dev/null

is "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_DEBUG" "The log level is set based on the env var"
