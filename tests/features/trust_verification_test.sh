source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                             Trusting the local env
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup
source .bash_profile # Imitate global env

# ==============================================================================
# xxxx When we go to a project with an untrusted local env file
actual_warning_message=$(SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_INFO" ; cd project_1)
expected_warning_message="The local env file is not trusted."

# ++++ It warns the user
assert_contain "$actual_warning_message" "$expected_warning_message" "It warns when the local env file is not trusted"

# ++++ And it doesn't load the local env
cd project_1
assert_equal "$var_1" "GLOBAL VAR" "Untrusted local env is not loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Untrusted local env is not loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Untrusted local env is not loaded (function)"

# xxxx When the user trusts the local env file
sherpa trust

# ++++ It loads the local env
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Local env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Local env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Local env is loaded (function)"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                            Untrusting the local env
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# xxxx When the user untrusts the local env
sherpa untrust

# ++++ It unloads the local env
assert_equal "$var_1" "GLOBAL VAR" "Local env is not unloaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Local env is not unloaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Local env is not unloaded (function)"

cd ..
cd project_1

# ++++ And it untrusts the local env -> It won't load it anymore
assert_equal "$var_1" "GLOBAL VAR" "Untrusted local env is not loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Untrusted local env is not loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Untrusted local env is not loaded (function)"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                  Trust check
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# In ubuntu I couldn't make the .envrc file unreadable
if [ "$RUNNING_IN_CONTAINER" = "true" ]; then
  echo "Running in container. Skipping the trust check test!"
  exit 0
fi

# ==============================================================================
# ++++ It warns the user when the local env file is not readable

STDERR_FILE=$(mktemp)
cleanup_file_or_dir_at_teardown "$STDERR_FILE"

mkdir -p ../tmp

touch "../tmp/$SHERPA_ENV_FILENAME"
chmod a-r "../tmp/$SHERPA_ENV_FILENAME"

SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_ERROR"
cd ../tmp 2> "$STDERR_FILE"

expected_warning_message="The local env file is not readable."
assert_contain "$(cat "$STDERR_FILE")" "$expected_warning_message" "It warns when the local env file is not readable"
