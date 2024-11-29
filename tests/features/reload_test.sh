source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                              Manual env reloading
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

stub_env_file
overwrite_env_file 'alias alias_1="echo alias_1"'
cd /
sherpa trust

# == Sanity checks: the env file is loaded
assert_equal "$(alias_1)" "alias_1"

# ==============================================================================
# The env file gets changed and trusted somewhere else

overwrite_env_file 'alias alias_2="echo changed"'
_sherpa_trust_current_dir

# ==============================================================================
# ++++ It reloads the environment for the current directory

sherpa reload

assert_undefined "alias_1"
assert_equal "$(alias_2)" "changed"
