source tests/support/app_helper.sh

# Setup
source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"
_sherpa_trust_dir "project_2"


# When Sherpa is enabled and we go to a project with a local env file
cd project_1
# Vigilant Sherpa loads the local env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Local env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Local env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Local env is loaded (function)"

# When the user disables Sherpa
sherpa off

# Sherpa unloaded the local env and goes to sleep
assert_equal "$var_1" "GLOBAL VAR" "Local env is unloaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Local env is unloaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Local env is unloaded (function)"

# When we go to another project with a local env file while Sherpa is sleeping
cd ../project_2
# Sleeping Sherpa doesn't load any env
assert_equal "$var_1" "GLOBAL VAR" "Local env is NOT loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Local env is NOT loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Local env is NOT loaded (function)"

# When the user wakes the Sherpa up
sherpa work

# Sherpa wakes up and loads the local env
assert_equal "$var_1" "LOCAL VAR PROJECT 2" "Local env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 2" "Local env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 2" "Local env is loaded (function)"
