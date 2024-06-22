source lib/init.zsh

SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"

# Load testing library
source tests/lib/tap-functions

plan_tests 12

# Start the test
cd tests/playground
# Load the global env

echo "==== Original env ===="

source .bash_profile
like "$var_1" "ORIGINAL VAR"
like "$(alias_1)" "ORIGINAL ALIAS"
like "$(function_1)" "ORIGINAL FUNCTION"

# Load the project env
echo "\n==== Project 1 env ===="
cd project_1
trust_local_sherpa
like "$var_1" "VAR PROJECT 1"
like "$(alias_1)" "ALIAS PROJECT 1"
like "$(function_1)" "FUNCTION PROJECT 1"

echo "\n==== Project 2 env ===="
cd ../project_2
trust_local_sherpa
like "$var_1" "VAR PROJECT 2"
like "$(alias_1)" "ALIAS PROJECT 2"
like "$(function_1)" "FUNCTION PROJECT 2"

echo "\n==== Original env again ===="
cd ..
like "$var_1" "ORIGINAL VAR"
like "$(alias_1)" "ORIGINAL ALIAS"
like "$(function_1)" "ORIGINAL FUNCTION"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
