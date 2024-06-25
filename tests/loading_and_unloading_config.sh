source lib/init.zsh

# Load testing library
source tests/lib/tap-functions

SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"

plan_no_plan

# Start the test
cd tests/playground
# Load the global env
source .bash_profile

echo "==== Original env ===="
is $var_1 "ORIGINAL VAR"
is "$(alias_1)" "ORIGINAL ALIAS"
is "$(function_1)" "ORIGINAL FUNCTION"

# Load the Project 1 env
echo "\n==== Project 1 env ===="
cd project_1
trust_local_sherpa
is $var_1 "VAR PROJECT 1"
is "$(alias_1)" "ALIAS PROJECT 1"
is "$(function_1)" "FUNCTION PROJECT 1"

# Unload the Project 1 env
# Load the Project 2 env
echo "\n==== Project 2 env ===="
cd ../project_2
trust_local_sherpa
is $var_1 "VAR PROJECT 2"
is "$(alias_1)" "ALIAS PROJECT 2"
is "$(function_1)" "FUNCTION PROJECT 2"

# Unload the Project 2 env
echo "\n==== Original env again ===="
cd ..
is "$var_1" "ORIGINAL VAR"
is "$(alias_1)" "ORIGINAL ALIAS"
is "$(function_1)" "ORIGINAL FUNCTION"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
