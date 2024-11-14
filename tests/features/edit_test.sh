source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                        Editing the env file via Sherpa
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

cd project_1
sherpa trust
# shellcheck disable=SC2154
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "The env is loaded"


# ==============================================================================
# xxxx When the user saves and closes the env file
# ++++ It auto trusts the env file and loads it

EDITOR="perl -pi -e 's/LOCAL VAR PROJECT 1/LOCAL VAR PROJECT 8/'" sherpa edit  > /dev/null
assert_equal "$var_1" "LOCAL VAR PROJECT 8" "The updated env is re-trusted and reloaded"
