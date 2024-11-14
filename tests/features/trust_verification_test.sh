source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                             Trusting the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup
source .bash_profile # Imitate global env

# ==============================================================================
# xxxx When we go to a project with an untrusted env file
actual_warning_message=$(SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_INFO" ; cd project_1)
expected_warning_message="The env file is not trusted."

# ++++ It warns the user
assert_contain "$actual_warning_message" "$expected_warning_message" "It warns when the env file is not trusted"

# ++++ And it doesn't load the env
cd project_1
assert_equal "$var_1" "GLOBAL VAR" "Untrusted env is not loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Untrusted env is not loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Untrusted env is not loaded (function)"

# xxxx When the user trusts the env file
sherpa trust

# ++++ It loads the env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Env is loaded (function)"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                            Untrusting the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# xxxx When the user untrusts the env file
sherpa untrust

# ++++ It unloads the env
assert_equal "$var_1" "GLOBAL VAR" "Env is not unloaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Env is not unloaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Env is not unloaded (function)"

cd ..
cd project_1

# ++++ And it untrusts the env file -> It won't load it anymore
assert_equal "$var_1" "GLOBAL VAR" "Untrusted Env is not loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Untrusted Env is not loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Untrusted Env is not loaded (function)"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                  Trust check
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# In ubuntu I couldn't make the .envrc file unreadable
if [ "$RUNNING_IN_CONTAINER" = "true" ]; then
  echo "Running in container. Skipping the trust check test!"
  exit 0
fi

# ==============================================================================
# ++++ It warns the user when the env file is not readable

STDERR_FILE=$(mktemp)
cleanup_file_or_dir_at_teardown "$STDERR_FILE"

mkdir -p ../tmp

touch "../tmp/$SHERPA_ENV_FILENAME"
chmod a-r "../tmp/$SHERPA_ENV_FILENAME"

SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_ERROR"
cd ../tmp 2> "$STDERR_FILE"

expected_warning_message="The env file is not readable."
assert_contain "$(cat "$STDERR_FILE")" "$expected_warning_message" "It warns when the env file is not readable"
