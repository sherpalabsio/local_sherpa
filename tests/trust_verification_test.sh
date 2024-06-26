source tests/lib/init.sh

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
is "$var_1" "ORIGINAL VAR"
is "$(alias_1)" "ORIGINAL ALIAS"
is "$(function_1)" "ORIGINAL FUNCTION"
sherpa trust
is "$var_1" "VAR PROJECT 1"
is "$(alias_1)" "ALIAS PROJECT 1"
is "$(function_1)" "FUNCTION PROJECT 1"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
