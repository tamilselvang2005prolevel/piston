FROM buildpack-deps:bullseye AS isolate
RUN apt-get update && \
    apt-get install -y --no-install-recommends git libcap-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/envicutor/isolate.git /tmp/isolate/ && \
    cd /tmp/isolate && \
    git checkout af6db68042c3aa0ded80787fbb78bc0846ea2114 && \
    make -j$(nproc) install && \
    rm -rf /tmp/*

FROM node:18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y libxml2 gnupg tar coreutils util-linux libc6-dev \
    binutils build-essential locales libpcre3-dev libevent-dev libgmp3-dev \
    libncurses6 libncurses5 libedit-dev libseccomp-dev rename procps python3 \
    libreadline-dev libblas-dev liblapack-dev libarpack2-dev libfftw3-dev \
    libglpk-dev libqhull-dev libqrupdate-dev libsuitesparse-dev libsundials-dev \
    libpcre2-dev libcap-dev wget curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -M piston
COPY --from=isolate /usr/local/bin/isolate /usr/local/bin
COPY --from=isolate /usr/local/etc/isolate /usr/local/etc/isolate

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

WORKDIR /api
COPY ["package.json", "package-lock.json", "./"]
RUN npm install
COPY ./src ./src
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENV PISTON_FETCH_PACKAGES=true
CMD ["/start.sh"]

EXPOSE 2000/tcp
