source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                 _sherpa_update_system::manual::is_there_updates
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It returns 1 when the versions are the same

NEW_SHERPA_VERSION="1.0.0"
    SHERPA_VERSION="1.0.0"

_sherpa_update_system::manual::is_there_updates "$NEW_SHERPA_VERSION"

assert_equal "$?" "1"

# ==============================================================================
# ++++ It returns 1 when the new version is lower than the current version

NEW_SHERPA_VERSION="1.0.0"
    SHERPA_VERSION="1.1.0"

_sherpa_update_system::manual::is_there_updates "$NEW_SHERPA_VERSION"

assert_equal "$?" "1"

# ==============================================================================
# ++++ It returns 0 when the new version is higher than the current version

NEW_SHERPA_VERSION="1.1.0"
    SHERPA_VERSION="1.0.0"

_sherpa_update_system::manual::is_there_updates "$NEW_SHERPA_VERSION"

assert_equal "$?" "0"
