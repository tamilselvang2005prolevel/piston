# Stage 1: Build isolate
FROM buildpack-deps:bullseye AS isolate

RUN apt-get update && \
    apt-get install -y --no-install-recommends git libcap-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/envicutor/isolate.git /tmp/isolate/ && \
    cd /tmp/isolate && \
    git checkout af6db68042c3aa0ded80787fbb78bc0846ea2114 && \
    make -j$(nproc) install && \
    rm -rf /tmp/*


# Stage 2: Build the Piston API
FROM node:18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg-reconfigure -p critical dash
RUN apt-get update && \
    apt-get install -y libxml2 gnupg tar coreutils util-linux libc6-dev \
    binutils build-essential locales libpcre3-dev libevent-dev libgmp3-dev \
    libncurses6 libncurses5 libedit-dev libseccomp-dev rename procps python3 \
    libreadline-dev libblas-dev liblapack-dev libpcre3-dev libarpack2-dev \
    libfftw3-dev libglpk-dev libqhull-dev libqrupdate-dev libsuitesparse-dev \
    libsundials-dev libpcre2-dev libcap-dev wget && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -M piston

# Copy isolate binaries
COPY --from=isolate /usr/local/bin/isolate /usr/local/bin
COPY --from=isolate /usr/local/etc/isolate /usr/local/etc/isolate

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Set work directory
WORKDIR /api

# Install dependencies
COPY ["package.json", "package-lock.json", "./"]
RUN npm install

# Copy source
COPY ./src ./src

# Download runtimes directly (✅ replaces package tarballs)
RUN mkdir -p /runtimes && \
    cd /runtimes && \
    wget -q https://github.com/engineer-man/piston/releases/download/pkgs-v3/python-3.12.0.pkg.tar.gz && \
    wget -q https://github.com/engineer-man/piston/releases/download/pkgs-v3/c.pkg.tar.gz && \
    wget -q https://github.com/engineer-man/piston/releases/download/pkgs-v3/cpp.pkg.tar.gz && \
    wget -q https://github.com/engineer-man/piston/releases/download/pkgs-v3/java-15.0.2.pkg.tar.gz && \
    wget -q https://github.com/engineer-man/piston/releases/download/pkgs-v3/node-18.15.0.pkg.tar.gz && \
    for f in *.tar.gz; do tar -xzf "$f"; rm "$f"; done

# Copy and set entrypoint
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Start server
CMD ["/start.sh"]

EXPOSE 2000/tcp
