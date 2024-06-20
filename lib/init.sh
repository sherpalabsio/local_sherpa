source ../vendor/smartcd/arrays
source ../vendor/smartcd/smartcd
source ../vendor/smartcd/varstash

function chpwd() {
  if [[ -n $OLDPWD && $PWD != $OLDPWD ]]; then
    varstash_dir=$OLDPWD
    unload_previous_local_config $OLDPWD
    varstash_dir=$PWD
    load_local_config $PWD
  fi
  export OLDPWD=$PWD
}

autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd

unload_previous_local_config() {
  unstash var_1
  # autounstash
  echo "Config unloaded."
}

load_local_config() {
  if [ -f .local-sherpa ]; then
    stash_local_config
    source .local-sherpa
    echo "Config loaded."
  fi
}

stash_local_config() {
  stash var_1
}
