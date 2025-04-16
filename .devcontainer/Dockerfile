# Use the latest Ruby 3.3 image
FROM mcr.microsoft.com/devcontainers/ruby:3.3

# Set environment variables
ENV NODE_VERSION=23

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    graphviz \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Fix Yarn conflict (if needed)
RUN rm -f /usr/bin/yarnpkg /usr/bin/yarn

# Install Ruby 3.4.2 using ruby-install
RUN curl -fsSL https://github.com/postmodern/ruby-install/archive/v0.8.2.tar.gz | tar xz && \
    cd ruby-install-0.8.2 && \
    make install && \
    ruby-install --system ruby 3.4.2 && \
    rm -rf ruby-install-0.8.2
