source lib/init.zsh

# Load testing library
source tests/lib/tap-functions

plan_tests 12

# Start the test
cd tests/playground
# Load the global config

echo "==== Original config ===="

source .bash_profile
like "$var_1" "ORIGINAL VAR"
like "$(alias_1)" "ORIGINAL ALIAS"
like "$(function_1)" "ORIGINAL FUNCTION"

# Load the project config
echo "\n==== Project 1 config ===="
cd project_1
like "$var_1" "VAR PROJECT 1"
like "$(alias_1)" "ALIAS PROJECT 1"
like "$(function_1)" "FUNCTION PROJECT 1"

echo "\n==== Project 2 config ===="
cd ../project_2
like "$var_1" "VAR PROJECT 2"
like "$(alias_1)" "ALIAS PROJECT 2"
like "$(function_1)" "FUNCTION PROJECT 2"

echo "\n==== Original config again ===="
cd ..
like "$var_1" "ORIGINAL VAR"
like "$(alias_1)" "ORIGINAL ALIAS"
like "$(function_1)" "ORIGINAL FUNCTION"
