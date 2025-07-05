FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    zsh

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
