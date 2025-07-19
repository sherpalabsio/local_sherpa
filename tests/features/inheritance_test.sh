source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                  Inheritance
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

function_name() {
  echo "Original function"
}

mkdir tmp

# ==============================================================================
# ++++ It calls the parent function

cat <<EOF > tmp/.envrc
function_name() {
  super
  echo "Overridden function"
}
EOF

_sherpa_trust_dir "tmp"

cd tmp

actual=$(function_name)
expected="Original function
Overridden function"

assert_equal "$actual" "$expected" "Parent function was called"

# ==============================================================================
# ++++ It unloads the temporary parent function

# Sanity check
assert_defined "__super_function_name" "Temporary parent function exists"

cd ..

assert_undefined "__super_function_name" "Temporary parent function was removed"
