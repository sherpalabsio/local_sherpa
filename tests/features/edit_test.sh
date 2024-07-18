source tests/support/init.sh

# Setup
cd project_1
sherpa trust
# shellcheck disable=SC2154
is "$var_1" "LOCAL VAR PROJECT 1" "The local env is loaded"


# When editing the local env file with Sherpa
# It opens the default editor
EDITOR="perl -pi -e 's/LOCAL VAR PROJECT 1/LOCAL VAR PROJECT 8/'" sherpa edit  > /dev/null

# When the user saves and closes the local env file
# Sherpa auto trusts the local env file and loads it
is "$var_1" "LOCAL VAR PROJECT 8" "The updated local env is re-trusted and reloaded"
