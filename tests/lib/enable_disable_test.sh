source tests/support/init.sh

plan_no_plan

# Start the test
cd tests/playground
# Load the global env
source .bash_profile

# Sherpa is awake so it loads the local env
cd project_1
sherpa trust
is $var_1 "LOCAL VAR PROJECT 1" "Project 1 var is loaded"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1"

# Disable Sherpa
sherpa rest

# Sherpa unloaded the local env and goes to sleep
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"

# Sherpa is sleeping so it doesn't load the local env
cd ../project_2
sherpa trust
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"

# Enable Sherpa
sherpa work

# Sherpa wakes up and loads the local env
is $var_1 "LOCAL VAR PROJECT 2"
is "$(alias_1)" "LOCAL ALIAS PROJECT 2"
is "$(function_1)" "LOCAL FUNCTION PROJECT 2"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
