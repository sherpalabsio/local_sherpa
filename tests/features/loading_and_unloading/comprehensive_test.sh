source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                      Comprehensive loading and unloading
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"
_sherpa_trust_dir "project_1/subfolder_with_no_local_env/subproject"
_sherpa_trust_dir "project_2"

# == Senety checks: the Global env is loaded
assert_equal "$var_1" "GLOBAL VAR" "Global env is ready (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Global env is ready (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Global env is ready (function)"


# ==============================================================================
# PWD: /project_1

cd project_1

# ++++ It loads the Project 1 env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Local env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Local env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Local env is loaded (function)"

# shellcheck disable=SC2154
assert_equal "$custom_var_1" "CUSTOM LOCAL VAR PROJECT 1" "Project 1 env is loaded (custom_var_1)"
assert_equal "$(custom_alias_1)" "CUSTOM LOCAL ALIAS PROJECT 1" "Project 1 env is loaded (custom_alias_1)"
assert_equal "$(custom_function_1)" "CUSTOM LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded (custom_function_1)"


# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env

cd subfolder_with_no_local_env

# ++++ It does not unload the Project 1 env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is not unloaded (alias_1)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"


# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env/subproject

cd subproject

# ++++ It does not unload the Project 1 env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ++++ It overrides the Project 1 env with the Subproject env
assert_equal "$(alias_1)" "LOCAL ALIAS SUBPROJECT" "Project 1 env is overridden by Subproject env (alias_1)"

# ++++ It loads the Subproject env
# shellcheck disable=SC2154
assert_equal "$subvar_1" "CUSTOM LOCAL VAR SUBPROJECT" "Subproject env is loaded (subvar_1)"
assert_equal "$(subalias_1)" "CUSTOM LOCAL ALIAS SUBPROJECT" "Subproject env is loaded (subalias_1)"
assert_equal "$(subfunction_1)" "CUSTOM LOCAL FUNCTION SUBPROJECT" "Subproject env is loaded (subfunction_1)"


# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env

cd ..

# ++++ It does not unload the Project 1 env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ++++ It restores the Project 1 env (rolls back the subproject overrides)
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is restored (alias_1)"

# ++++ It unloads the Subproject env
assert_undefined "subvar_1" "Subproject env is unloaded (subvar_1)"
assert_undefined "subalias_1" "Subproject env is unloaded (subalias_1)"
assert_undefined "subfunction_1" "Subproject env is unloaded (subfunction_1)"


# ==============================================================================
# PWD: /project_1

cd ..

# ++++ It does not unload the Project 1 env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is not unloaded (alias_1)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"


# ==============================================================================
# PWD: /

cd ..

# ++++ It restores the Global env (rolls back the project_1 overrides)
assert_equal "$var_1" "GLOBAL VAR" "Global env is restored (var_1)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Global env is restored (alias_1)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Global env is restored (function_1)"

# ++++ It unloads the Project 1 env
assert_undefined "custom_var_1" "Subproject env is unloaded (custom_var_1)"
assert_undefined "custom_alias_1" "Subproject env is unloaded (custom_alias_1)"
assert_undefined "custom_function_1" "Subproject env is unloaded (custom_function_1)"


# ==============================================================================
# PWD: /project_1

cd project_1

# ++++ It loads the Project 1 env again
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is loaded again (var_1)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is loaded again (alias_1)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded again (function_1)"

assert_equal "$custom_var_1" "CUSTOM LOCAL VAR PROJECT 1" "Project 1 env is loaded again (custom_var_1)"
assert_equal "$(custom_alias_1)" "CUSTOM LOCAL ALIAS PROJECT 1" "Project 1 env is loaded again (custom_alias_1)"
assert_equal "$(custom_function_1)" "CUSTOM LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded again (custom_function_1)"


# ==============================================================================
# PWD: /project_2

cd ../project_2

# ++++ It unloads the Project 1 env
assert_undefined "custom_var_1" "Subproject env is unloaded (custom_var_1)"
assert_undefined "custom_alias_1" "Subproject env is unloaded (custom_alias_1)"
assert_undefined "custom_function_1" "Subproject env is unloaded (custom_function_1)"

# ++++ It loads the Project 2 env
assert_equal "$var_1" "LOCAL VAR PROJECT 2" "Previous env is unloaded, local env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 2" "Previous env is unloaded, local env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 2" "Previous env is unloaded, local env is loaded (function)"
