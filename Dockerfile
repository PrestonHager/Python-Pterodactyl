# Custom Python Docker image for Pterodactyl with uv package manager
# Based on Pterodactyl yolks: https://raw.githubusercontent.com/pterodactyl/yolks/refs/heads/master/python/3.11/Dockerfile

ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-alpine

LABEL author="Preston Hager" maintainer="me@prestonhager.com"
LABEL org.opencontainers.image.source="https://github.com/PrestonHager/python-uv-pterodactyl-egg"
LABEL org.opencontainers.image.licenses=MIT

# Install system dependencies, build tools, and uv package manager
RUN apk add --update --no-cache \
    curl \
    git \
    ca-certificates \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    openssl-dev \
    zlib-dev \
    jpeg-dev \
    freetype-dev \
    lcms2-dev \
    openjpeg-dev \
    tiff-dev \
    tk-dev \
    tcl-dev \
    harfbuzz-dev \
    fribidi-dev \
    libimagequant-dev \
    libxcb-dev \
    libpng-dev \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && chmod +x /usr/local/bin/uv

# Copy entrypoint script and set permissions
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create container user (following Pterodactyl yolks pattern)
RUN adduser -D -h /home/container container

USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

CMD ["/bin/ash", "/entrypoint.sh"]
