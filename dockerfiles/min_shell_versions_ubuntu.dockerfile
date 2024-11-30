FROM ubuntu:20.04

ENV RUNNING_IN_CONTAINER=true

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    libncurses5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Bash 4.3
RUN wget https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz \
    && tar xf bash-4.3.tar.gz \
    && cd bash-4.3 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf bash-4.3*

# Replace default shell with the new bash
RUN ln -sf /usr/local/bin/bash /bin/bash

# Set Bash as the default shell for the root user
RUN chsh -s /usr/local/bin/bash root

# Set Bash as the default shell for all users
RUN echo "/usr/local/bin/bash" >> /etc/shells

# Install Zsh 5.3.1
RUN wget https://sourceforge.net/projects/zsh/files/zsh/5.3.1/zsh-5.3.1.tar.gz \
    && tar xf zsh-5.3.1.tar.gz \
    && cd zsh-5.3.1 \
    # Get updated config.guess and config.sub
    && wget -O config.guess 'https://git.savannah.gnu.org/cgit/config.git/plain/config.guess' \
    && wget -O config.sub 'https://git.savannah.gnu.org/cgit/config.git/plain/config.sub' \
    && chmod +x config.guess config.sub \
    && ./configure --prefix=/usr/local/bin/zsh --without-tcsetpgrp \
    && make \
    && make install \
    && cd .. \
    && rm -rf zsh-5.3.1*

RUN ln -sf /usr/local/bin/zsh/bin/zsh /bin/zsh

WORKDIR /app
COPY . .

CMD ["/bin/bash"]
