_sherpa_update_system() {
  if [[ "$SHERPA_DIR" == *"/homebrew/"* ]]; then
    _sherpa_update_system::homebrew
  else
    _sherpa_update_system::manual
  fi
}

_sherpa_update_system::homebrew() {
  echo "==> Homebrew installation detected"

  brew update

  echo "==> Checking for updates"

  if brew outdated local_sherpa > /dev/null; then
    echo "You are already using the latest version."
  else
    echo "==> Updating Sherpa"
    brew upgrade local_sherpa
  fi
}

_sherpa_update_system::manual() {
  echo "==> Manual installation detected"
  local github_latest_version

  github_latest_version="$(_sherpa_update_system::manual::get_latest_version)"

  if ! _sherpa_update_system::manual::is_there_updates "$github_latest_version"; then
    echo "There is nothing to update."
    return
  fi

  echo "==> Updating from $SHERPA_VERSION to $github_latest_version"

  _sherpa_update_system::manual::download_latest_version "$github_latest_version"
  _sherpa_update_system::manual::install "$github_latest_version"
  _sherpa_update_system::manual::cleanup

  echo "==> Reloading Sherpa"
  sherpa off > /dev/null
  eval "$(local_sherpa_init)"
  sherpa on > /dev/null

  echo "==> Done"
}

_sherpa_update_system::manual::get_latest_version() {
  local github_latest_version

  github_latest_version=$(
    curl -sL -H 'Accept: application/json' https://github.com/sherpalabsio/local_sherpa/releases/latest |
      sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'
  )
  echo "${github_latest_version//v/}"
}

_sherpa_update_system::manual::download_latest_version() {
  echo "==> Downloading files"

  local github_latest_version github_file github_url
  github_latest_version="$1"

  github_file="local_sherpa_$github_latest_version.tar.gz"
  github_url="https://github.com/sherpalabsio/local_sherpa/releases/download/v${github_latest_version}/${github_file}"

  curl -sL -o local_sherpa.tar.gz "$github_url"
}

_sherpa_update_system::manual::install() {
  local -r github_latest_version="$1"

  local installation_root_dir
  installation_root_dir=$(dirname "$SHERPA_DIR")

  echo "==> Installing to $installation_root_dir"

  tar -xzf local_sherpa.tar.gz -C "$installation_root_dir"

  echo "==> Updating the local_sherpa_init symlink"
  ln -sf "$installation_root_dir/local_sherpa_$github_latest_version/init" "$(command -v local_sherpa_init)"
}

_sherpa_update_system::manual::cleanup() {
  echo "==> Removing the old installation"

  rm -rf "$SHERPA_DIR"
  rm -f local_sherpa.tar.gz
}

_sherpa_update_system::manual::is_there_updates() {
  local -r latest_version="$1"

  IFS='.' read -r current_major current_minor current_patch <<< "$SHERPA_VERSION"
  IFS='.' read -r latest_major latest_minor latest_patch <<< "$latest_version"

  [ "$latest_major" -gt "$current_major" ] && return 0
  [ "$latest_minor" -gt "$current_minor" ] && return 0
  [ "$latest_patch" -gt "$current_patch" ] && return 0

  return 1
}
