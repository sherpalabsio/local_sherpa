source tests/support/init.sh

plan_no_plan

# Setup
cd playground
source .bash_profile # Imitate global env


echo "==== Original env ===="
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"

# Load the Project 1 env
printf "\n==== Project 1 env ===="
cd project_1
sherpa trust
is "$var_1" "LOCAL VAR PROJECT 1"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1"

# Unload the Project 1 env
# Load the Project 2 env
printf "\n==== Project 2 env ===="
cd ../project_2
sherpa trust
is "$var_1" "LOCAL VAR PROJECT 2"
is "$(alias_1)" "LOCAL ALIAS PROJECT 2"
is "$(function_1)" "LOCAL FUNCTION PROJECT 2"

# Unload the Project 2 env
printf "\n==== Original env again ===="
cd ..
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
