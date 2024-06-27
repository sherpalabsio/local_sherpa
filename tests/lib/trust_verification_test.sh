source tests/support/init.sh

plan_no_plan

# Start the test
cd tests/playground
# Load the global env
source .bash_profile


actual_warning_message=$(SHERPA_LOG_LEVEL='info' ; cd project_1)
expected_warning_message="The local env file is not trusted."

like $actual_warning_message $expected_warning_message 'It warns when the local env file is not trusted'

# It will not load untrusted local env file
cd project_1
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"
sherpa trust
is "$var_1" "LOCAL VAR PROJECT 1"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
