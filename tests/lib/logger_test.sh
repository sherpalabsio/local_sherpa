source tests/support/app_helper.sh

export SHERPA_ENV_FILENAME="../fixtures/parsing/$SHERPA_ENV_FILENAME"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                       Setters and getters for log level
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It sets the log level correctly from numbers
unset SHERPA_LOG_LEVEL

_sherpa_set_log_level $SHERPA_LOG_LEVEL_WARN

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_WARN"
assert_equal "$(_sherpa_get_log_level_in_text)" "warn"

# ==============================================================================
# ++++ It sets the log level correctly from text
unset SHERPA_LOG_LEVEL

_sherpa_set_log_level "debug"

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_DEBUG"
assert_equal "$(_sherpa_get_log_level_in_text)" "debug"

# ==============================================================================
# ++++ It sets the log level correctly when the input is invalid
unset SHERPA_LOG_LEVEL

_sherpa_set_log_level "invalid"

assert_equal "$SHERPA_LOG_LEVEL" "$SHERPA_LOG_LEVEL_SILENT"
assert_equal "$(_sherpa_get_log_level_in_text)" "silent 🤫"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                       Increasing the log level
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It increases the log level correctly
unset SHERPA_LOG_LEVEL
_sherpa_set_log_level 1

_sherpa_decrease_log_level

assert_equal "$SHERPA_LOG_LEVEL" 0 "The log level is increased correctly"

# ==============================================================================
# ++++ It does not increase the log level when it is already at the highest
unset SHERPA_LOG_LEVEL
_sherpa_set_log_level 0

_sherpa_decrease_log_level > /dev/null

assert_equal "$SHERPA_LOG_LEVEL" 0 "The log level is not increased when it is already at the highest"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                       Decreasing the log level
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It decreases the log level correctly
unset SHERPA_LOG_LEVEL
_sherpa_set_log_level 1

_sherpa_increase_log_level

assert_equal "$SHERPA_LOG_LEVEL" 2 "The log level is decreased correctly"

# ==============================================================================
# ++++ It does not decrease the log level when it is already at the lowest
unset SHERPA_LOG_LEVEL
_sherpa_set_log_level 4

_sherpa_increase_log_level > /dev/null

assert_equal "$SHERPA_LOG_LEVEL" 4 "The log level is not decreased when it is already at the lowest"
