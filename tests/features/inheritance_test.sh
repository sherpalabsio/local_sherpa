source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                  Inheritance
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

function_name() {
  echo "Original function"
}

alias alias_name="echo Original alias"

mkdir tmp

# ==============================================================================
# ++++ It calls the parent function or alias

cat <<EOF > tmp/.envrc
function_name() {
  super
  echo "Overridden function"
}

alias_name() {
  super
  echo "Overridden alias"
}
EOF

_sherpa_trust_dir "tmp"

cd tmp

actual=$(function_name)
expected="Original function
Overridden function"

assert_equal "$actual" "$expected" "Parent function was called"

actual=$(alias_name)
expected="Original alias
Overridden alias"

assert_equal "$actual" "$expected" "Parent alias was called"

# ==============================================================================
# ++++ It unloads the temporary parent function

# Sanity check
assert_defined "__super_function_name" "Temporary parent function exists"
assert_defined "__super_alias_name" "Temporary parent function exists"

cd ..

assert_undefined "__super_function_name" "Temporary parent function was removed"
assert_undefined "__super_alias_name" "Temporary parent function was removed"

# ==============================================================================
# xxxx When the parent is not existing
# ++++ It prints an error message

cat <<EOF > tmp/.envrc
non_existent_parent() {
  super
  echo "Overridden function"
}
EOF

_sherpa_trust_dir "tmp"

cd tmp

actual=$(SHERPA_LOG_LEVEL="$SHERPA_LOG_LEVEL_ERROR" non_existent_parent 2>&1)
expected="The parent 'non_existent_parent' does not exist"

assert_contain "$actual" "$expected" "Error message was displayed"
