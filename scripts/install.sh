HOME_LOCAL_DIR="$HOME/.local"

# Check if version argument is provided, otherwise get latest from GitHub
if [ -n "$1" ]; then
  TARGET_VERSION="$1"
  # Remove 'v' prefix if present
  TARGET_VERSION=${TARGET_VERSION//v/}
  echo "==> Using specified version ($TARGET_VERSION)"
else
  TARGET_VERSION=$(
    curl -sL -H 'Accept: application/json' https://github.com/sherpalabsio/local_sherpa/releases/latest |
      sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'
  )
  TARGET_VERSION=${TARGET_VERSION//v/}
  echo "==> Using latest version from GitHub ($TARGET_VERSION)"
fi

GITHUB_FILE="local_sherpa_$TARGET_VERSION.tar.gz"
GITHUB_URL="https://github.com/sherpalabsio/local_sherpa/releases/download/v${TARGET_VERSION}/${GITHUB_FILE}"

echo "==> Downloading files"
curl -sL -o local_sherpa.tar.gz "$GITHUB_URL"

if [ -d "$HOME_LOCAL_DIR/lib/local_sherpa_$TARGET_VERSION" ]; then
  echo -e "==> \e[33mRemoving existing installation $HOME_LOCAL_DIR/lib/local_sherpa_$TARGET_VERSION\e[0m"
  rm -rf "$HOME_LOCAL_DIR/lib/local_sherpa_$TARGET_VERSION"
fi

echo "==> Installing to $HOME_LOCAL_DIR/lib/local_sherpa_$TARGET_VERSION"
mkdir -p "$HOME_LOCAL_DIR/bin" "$HOME_LOCAL_DIR/lib"

tar --warning=no-unknown-keyword -xzf local_sherpa.tar.gz -C "$HOME_LOCAL_DIR/lib"
ln -sf "$HOME_LOCAL_DIR/lib/local_sherpa_$TARGET_VERSION/init" "$HOME_LOCAL_DIR/bin/local_sherpa_init"
rm -f local_sherpa.tar.gz

if [[ "$SHELL" == *"zsh" ]]; then
  SHELL_CONFIG="$HOME/.zshrc"
else
  SHELL_CONFIG="$HOME/.bashrc"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  # shellcheck disable=SC2016
  echo 'export PATH="$HOME/.local/bin:$PATH" # Local Sherpa install' >> "$SHELL_CONFIG"
  echo "==> ~/.local/bin was not in your PATH, I added it to $SHELL_CONFIG"
fi

echo "eval \"\$(local_sherpa_init)\"" >> "$SHELL_CONFIG"
echo "==> Added \`eval \"\$(local_sherpa_init)\"\` to $SHELL_CONFIG"

echo -e "==> \e[32mDone\e[0m (Don't forget to restart your shell)"
