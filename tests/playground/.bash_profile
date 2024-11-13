export var_1='GLOBAL VAR'

alias alias_1='echo "GLOBAL ALIAS"'

function_1() {
  echo "GLOBAL FUNCTION"
}

# Shadowing
alias existing_alias_shadowing_new_function='echo "ORIGINAL ALIAS"'

existing_function_shadowing_new_alias() {
  echo "ORIGINAL FUNCTION"
}
