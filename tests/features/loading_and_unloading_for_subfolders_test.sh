source tests/support/init.sh

# Setup
cd playground
source .bash_profile # Imitate global env


# Load the Project 1 env
printf "\n==== Project 1 env ====\n"
cd project_1
sherpa trust
is "$var_1" "LOCAL VAR PROJECT 1"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1"

# When we cd to project_1/subfolder which has no local env,
# it does not unload the Project 1 env
printf "\n==== Subfolder NO local env ====\n"
cd subfolder
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is not unloaded (alias_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# When we cd to project_1/subfolder/subproject, it does not unload the Project 1 env
# but loads the Subproject env which overrides the Project 1 env
printf "\n==== Subproject env ====\n"
cd subproject
sherpa trust
is "$var_1" "LOCAL VAR SUBPROJECT" "Project 1 env is overridden by Subproject env (var_1)"
is "$(alias_1)" "LOCAL ALIAS SUBPROJECT" "Project 1 env is overridden by Subproject env (alias_1)"
is "$(function_1)" "LOCAL FUNCTION SUBPROJECT" "Project 1 env is overridden by Subproject env (function_1)"

is "$subvar_1" "SUBLOCAL VAR SUBPROJECT" "Subproject env is loaded (subvar_1)"
is "$(subalias_1)" "SUBLOCAL ALIAS SUBPROJECT" "Subproject env is loaded (subalias_1)"
is "$(subfunction_1)" "SUBLOCAL FUNCTION SUBPROJECT" "Subproject env is loaded (subfunction_1)"

# When we cd back to project_1/subfolder, it unloads the Subproject env
# and restores the Project 1 env
cd ..

printf "\n==== Subfolder again ====\n"
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is restored (var_1)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is restored (alias_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is restored (function_1)"

is "_$subvar_1" "_" "Subfolder env is unloaded (subvar_1)"
error_message=$(is_item_defined_error_message subalias_1)
like "$error_message" "not found" "Subfolder env is unloaded (subalias_1)"
error_message=$(is_item_defined_error_message subfunction_1)
like "$error_message" "not found" "Subfolder env is unloaded (subalias_1)"

# When we cd back to project_1, it does not reload the Project 1 env
actual_warning_message=$(SHERPA_LOG_LEVEL='debug' ; cd ..)
expected_warning_message="Local env already loaded"

# Sherpa warns the user
like "$actual_warning_message" "$expected_warning_message" "It does not reload the Project 1 env"

# When we cd back to the root, it unloads the Project 1 env
# and restores the Global env
printf "\n==== Original env again ====\n"
cd ../..
is "$var_1" "GLOBAL VAR"
is "$(alias_1)" "GLOBAL ALIAS"
is "$(function_1)" "GLOBAL FUNCTION"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
