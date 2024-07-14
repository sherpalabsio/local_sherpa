FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends zsh git

ENV RUNNING_IN_CONTAINER=true

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
