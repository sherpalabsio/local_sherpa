source tests/support/init.sh

# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#                                      Setup
# ______________________________________________________________________________
cd playground
source .bash_profile # Imitate global env

# ++++ Senety checks: the Global env is loaded
is "$var_1" "GLOBAL VAR" "Global env is ready (var)"
is "$(alias_1)" "GLOBAL ALIAS" "Global env is ready (alias)"
is "$(function_1)" "GLOBAL FUNCTION" "Global env is ready (function)"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                       Comprehensive loading and unloading
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# PWD: /project_1

cd project_1
sherpa trust

# ++++ It loads the Project 1 env
is "$var_1" "LOCAL VAR PROJECT 1" "Local env is loaded (var)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Local env is loaded (alias)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Local env is loaded (function)"

# shellcheck disable=SC2154
is "$custom_var_1" "CUSTOM LOCAL VAR PROJECT 1" "Project 1 env is loaded (custom_var_1)"
is "$(custom_alias_1)" "CUSTOM LOCAL ALIAS PROJECT 1" "Project 1 env is loaded (custom_alias_1)"
is "$(custom_function_1)" "CUSTOM LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded (custom_function_1)"

# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env

cd subfolder_with_no_local_env

# ++++ It does not unload the Project 1 env
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is not unloaded (alias_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env/subproject

cd subproject
sherpa trust

# ++++ It does not unload the Project 1 env
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ++++ It overrides the Project 1 env with the Subproject env
is "$(alias_1)" "LOCAL ALIAS SUBPROJECT" "Project 1 env is overridden by Subproject env (alias_1)"

# ++++ It loads the Subproject env
# shellcheck disable=SC2154
is "$subvar_1" "CUSTOM LOCAL VAR SUBPROJECT" "Subproject env is loaded (subvar_1)"
is "$(subalias_1)" "CUSTOM LOCAL ALIAS SUBPROJECT" "Subproject env is loaded (subalias_1)"
is "$(subfunction_1)" "CUSTOM LOCAL FUNCTION SUBPROJECT" "Subproject env is loaded (subfunction_1)"

# ==============================================================================
# PWD: /project_1/subfolder_with_no_local_env

cd ..

# ++++ It does not unload the Project 1 env
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ++++ It restores the Project 1 env (rolls back the subproject overrides)
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is restored (alias_1)"

# ++++ It unloads the Subproject env
is_undefined "subvar_1" "Subproject env is unloaded (subvar_1)"
is_undefined "subalias_1" "Subproject env is unloaded (subalias_1)"
is_undefined "subfunction_1" "Subproject env is unloaded (subfunction_1)"

# ==============================================================================
# PWD: /project_1

cd ..

# ++++ It does not unload the Project 1 env
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is not unloaded (var_1)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is not unloaded (alias_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is not unloaded (function_1)"

# ==============================================================================
# PWD: /

cd ..

# ++++ It restores the Global env (rolls back the project_1 overrides)
is "$var_1" "GLOBAL VAR" "Global env is restored (var_1)"
is "$(alias_1)" "GLOBAL ALIAS" "Global env is restored (alias_1)"
is "$(function_1)" "GLOBAL FUNCTION" "Global env is restored (function_1)"

# ++++ It unloads the Project 1 env
is_undefined "custom_var_1" "Subproject env is unloaded (custom_var_1)"
is_undefined "custom_alias_1" "Subproject env is unloaded (custom_alias_1)"
is_undefined "custom_function_1" "Subproject env is unloaded (custom_function_1)"

# ==============================================================================
# PWD: /project_1

cd project_1

# ++++ It loads the Project 1 env again
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is loaded again (var_1)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Project 1 env is loaded again (alias_1)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded again (function_1)"

is "$custom_var_1" "CUSTOM LOCAL VAR PROJECT 1" "Project 1 env is loaded again (custom_var_1)"
is "$(custom_alias_1)" "CUSTOM LOCAL ALIAS PROJECT 1" "Project 1 env is loaded again (custom_alias_1)"
is "$(custom_function_1)" "CUSTOM LOCAL FUNCTION PROJECT 1" "Project 1 env is loaded again (custom_function_1)"

# ==============================================================================
# PWD: /project_2

cd ../project_2
sherpa trust

# ++++ It unloads the Project 1 env
is_undefined "custom_var_1" "Subproject env is unloaded (custom_var_1)"
is_undefined "custom_alias_1" "Subproject env is unloaded (custom_alias_1)"
is_undefined "custom_function_1" "Subproject env is unloaded (custom_function_1)"

# ++++ It loads the Project 2 env
is "$var_1" "LOCAL VAR PROJECT 2" "Previous env is unloaded, local env is loaded (var)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 2" "Previous env is unloaded, local env is loaded (alias)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 2" "Previous env is unloaded, local env is loaded (function)"
