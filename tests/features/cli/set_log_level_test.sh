source tests/support/app_helper.sh
_skip_for_zsh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                 Log level menu
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup
SHERPA_CONFIG_DIR="$TEST_DIR/playground/local_sherpa_config"

# == Senety check
assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT"

# ==============================================================================
# ++++ It sets the correct log level

actual_output=$(printf "%s" "1" | sherpa log)
expected_output="Sherpa: Log level set to: debug"

assert_contain "$actual_output" "$expected_output"
