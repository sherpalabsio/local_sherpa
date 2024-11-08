FROM ubuntu:20.04

ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh \
    locales && \
    locale-gen en_US.UTF-8

ENV RUNNING_IN_CONTAINER=true

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
