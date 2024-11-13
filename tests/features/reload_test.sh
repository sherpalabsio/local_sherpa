source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                           Local environment reloading
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

stub_env_file
overwrite_env_file 'alias alias_1="echo alias_1"'
cd /
sherpa trust

# == Senety checks: the local environment file is loaded
assert_equal "$(alias_1)" "alias_1"

# ==============================================================================
# xxxx When the local env file gets changed and trusted somewhere else

overwrite_env_file 'alias alias_2="echo changed"'
_sherpa_trust_current_dir

# ++++ It reloads the environment for the current directory

sherpa reload

assert_undefined "alias_1"
assert_equal "$(alias_2)" "changed"
