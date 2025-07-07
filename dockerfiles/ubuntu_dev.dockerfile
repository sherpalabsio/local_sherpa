FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh

WORKDIR /app
COPY . .

RUN ln -sf "/app/init" "/usr/local/bin/local_sherpa_init"

RUN echo 'eval "$(local_sherpa_init)"' >> "$HOME/.zshrc" && \
    echo 'eval "$(local_sherpa_init)"' >> "$HOME/.bashrc"

RUN echo '[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases' >> "$HOME/.zshrc"

CMD ["/bin/bash"]
