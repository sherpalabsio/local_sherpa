source lib/init.zsh

# Load testing library
source tests/lib/tap-functions

SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"

plan_no_plan

cd tests/playground/project_1
sherpa trust
is "$var_1" "VAR PROJECT 1"
# It opens the default editor
EDITOR="sed -i '' '1s/ 1/ 8/'" sherpa edit
# Then auto trusts the local env file and loads it
is "$var_1" "VAR PROJECT 8"

# Tear down
rm -rf $SHERPA_CHECKSUM_DIR
git checkout -- .local-sherpa
