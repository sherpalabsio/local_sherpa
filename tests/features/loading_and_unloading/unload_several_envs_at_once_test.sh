source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                         Unloading several envs at once
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup
source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"
_sherpa_trust_dir "project_1/subfolder_with_no_env/subproject"

# == Sanity checks: the Global env is loaded
assert_equal "$var_1" "GLOBAL VAR" "Global env is ready (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Global env is ready (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Global env is ready (function)"

# ==============================================================================
# PWD: /project_1 (with env)
cd project_1
# == Sanity check: Project 1 env is loaded
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Project 1 env is loaded (var_1)"

# ==============================================================================
# PWD: /project_1/subfolder_with_no_env (with no env)
cd subfolder_with_no_env

# ==============================================================================
# PWD: /project_1/subfolder_with_no_env/subproject (with env)
cd subproject
# == Sanity check: Subproject env is loaded
assert_equal "$(alias_1)" "LOCAL ALIAS SUBPROJECT" "Project 1 env is overridden by Subproject env (alias_1)"

# ==============================================================================
# ++++ It unloads the envs in the right order therefore it restores the stashed
# envs in the right order therefore we get the Global env back instead
# of the project_1 env

cd ../../..

assert_equal "$var_1" "GLOBAL VAR" "Global env is restored (var_1)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Global env is restored (alias_1)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Global env is restored (function_1)"
