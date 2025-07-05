FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh

ENV RUNNING_IN_CONTAINER=true

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
