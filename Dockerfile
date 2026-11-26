# PS5 Dump Forge (https://github.com/quer3q/ps5-dump-forge) — web UI in headless `serve` mode.
# Upstream publishes no image and its release CLI ships without the web UI, so this builds the
# CLI from the release tag with the UI embedded (same recipe as the old build.sh on Unraid).
#   docker build --build-arg FORGE_VERSION=v0.5.7 -t ps5-dump-forge .

FROM node:22-bookworm AS build
ARG FORGE_VERSION=v0.5.7
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends build-essential pkg-config curl git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable
ENV PATH=/root/.cargo/bin:$PATH \
    RUSTUP_TOOLCHAIN=stable
RUN git clone --depth 1 --branch "$FORGE_VERSION" https://github.com/quer3q/ps5-dump-forge /src
WORKDIR /src
RUN cd app && npm ci --no-audit --no-fund && npm run build:http
RUN FORGE_REQUIRE_WEB=1 cargo build --release -p ps5-dump-forge-cli

FROM debian:bookworm-slim
ARG FORGE_VERSION=v0.5.7
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends ca-certificates tini \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/target/release/ps5-dump-forge /usr/local/bin/ps5-dump-forge
# Forge keeps its state under XDG_DATA_HOME; /config is mapped to appdata on Unraid.
ENV HOME=/config \
    XDG_DATA_HOME=/config
RUN mkdir -p /config /games && chmod 777 /config /games
VOLUME ["/config"]
EXPOSE 8095
LABEL org.opencontainers.image.title="ps5-dump-forge" \
      org.opencontainers.image.description="PS5 Dump Forge web UI (serve mode), built from upstream release" \
      org.opencontainers.image.version="${FORGE_VERSION}" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.url="https://github.com/quer3q/ps5-dump-forge"
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/ps5-dump-forge", "serve", "--port", "8095"]
CMD ["--root", "/games"]
