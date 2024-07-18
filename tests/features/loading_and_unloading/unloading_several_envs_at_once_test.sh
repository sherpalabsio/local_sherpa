source tests/support/app_helper.sh

# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#                                      Setup
# ______________________________________________________________________________
source .bash_profile # Imitate global env

# ++++ Senety checks: the Global env is loaded
is "$var_1" "GLOBAL VAR" "Global env is ready (var)"
is "$(alias_1)" "GLOBAL ALIAS" "Global env is ready (alias)"
is "$(function_1)" "GLOBAL FUNCTION" "Global env is ready (function)"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                         Unloading several envs at once
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It unloads the local envs in the right order therefore
# it restores the stashed envs in the right order therefore
# we get the Global env back instead of the project_1 env

# == project_1 with local env
cd project_1
sherpa trust
# ++++ Senety check: Project 1 env is loaded
is "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is loaded (var_1)"

# == subfolder_with_no_local_env with no local env
cd subfolder_with_no_local_env

# == subproject with local env
cd subproject
sherpa trust
# ++++ Senety check: Subproject env is loaded
is "$(alias_1)" "LOCAL ALIAS SUBPROJECT" "Project 1 env is overridden by Subproject env (alias_1)"

cd ../../..
is "$var_1" "GLOBAL VAR" "Global env is restored (var_1)"
is "$(alias_1)" "GLOBAL ALIAS" "Global env is restored (alias_1)"
is "$(function_1)" "GLOBAL FUNCTION" "Global env is restored (function_1)"
