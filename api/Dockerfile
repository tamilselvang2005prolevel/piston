FROM node:18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y libxml2 gnupg tar coreutils util-linux build-essential locales && \
    rm -rf /var/lib/apt/lists/*

# Set up app directory
WORKDIR /api

# Copy dependencies
COPY ["package.json", "package-lock.json", "./"]
RUN npm install

# Copy source and packages
COPY ./src ./src
COPY ./packages ./packages

# Start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 2000/tcp
CMD ["/start.sh"]