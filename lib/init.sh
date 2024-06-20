function chpwd() {
  if [[ -n $OLDPWD && $PWD != $OLDPWD ]]; then
    echo "Left: $OLDPWD"
    echo "Entered: $PWD"
  fi
  export OLDPWD=$PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd

# Worked
# # autoload -U add-zsh-hook

# _smartcd_hook() {
#   echo 'AAAAA'
# }

# chpwd_functions=(${chpwd_functions[@]} "_smartcd_hook")
