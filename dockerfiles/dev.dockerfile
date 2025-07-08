FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh \
    curl \
    ca-certificates \
    tar

RUN curl -L https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_arm64.tar.gz | tar -xz -C /usr/local/bin/

WORKDIR /app
COPY . .

RUN ln -sf "/app/init" "/usr/local/bin/local_sherpa_init"

RUN echo 'eval "$(local_sherpa_init)"' >> "$HOME/.zshrc" && \
    echo 'eval "$(local_sherpa_init)"' >> "$HOME/.bashrc"

RUN echo '[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases' >> "$HOME/.zshrc"

CMD ["/bin/bash"]
