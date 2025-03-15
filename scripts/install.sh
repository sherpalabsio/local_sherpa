HOME_LOCAL_DIR="$HOME/.local"

GITHUB_LATEST_VERSION=$(
  curl -sL -H 'Accept: application/json' https://github.com/sherpalabsio/local_sherpa/releases/latest |
    sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'
)
GITHUB_LATEST_VERSION=${GITHUB_LATEST_VERSION//v/}

GITHUB_FILE="local_sherpa_$GITHUB_LATEST_VERSION.tar.gz"
GITHUB_URL="https://github.com/sherpalabsio/local_sherpa/releases/download/v${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

echo "==> Downloading the latest version ($GITHUB_LATEST_VERSION)"
curl -sL -o local_sherpa.tar.gz "$GITHUB_URL"

if [ -d "$HOME_LOCAL_DIR/lib/local_sherpa_$GITHUB_LATEST_VERSION" ]; then
  echo -e "==> \e[33mRemoving existing installation $HOME_LOCAL_DIR/lib/local_sherpa_$GITHUB_LATEST_VERSION\e[0m"
  rm -rf "$HOME_LOCAL_DIR/lib/local_sherpa_$GITHUB_LATEST_VERSION"
fi

echo "==> Installing to $HOME_LOCAL_DIR/lib/local_sherpa_$GITHUB_LATEST_VERSION"
mkdir -p "$HOME_LOCAL_DIR/bin" "$HOME_LOCAL_DIR/lib"

tar -xzf local_sherpa.tar.gz -C "$HOME_LOCAL_DIR/lib"
ln -sf "$HOME_LOCAL_DIR/lib/local_sherpa_$GITHUB_LATEST_VERSION/init" "$HOME_LOCAL_DIR/bin/local_sherpa_init"
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

echo -e "==> \e[32mDone\e[0m (Don't forget to restart your shell session)"
