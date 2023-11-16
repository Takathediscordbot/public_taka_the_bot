# Using the `rust-musl-builder` as base image, instead of 
# the official Rust toolchain
FROM clux/muslrust:stable AS chef
USER root
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS taka_the_discord_bot_dependencies
COPY --from=planner /app/recipe.json recipe.json
# Notice that we are specifying the --target flag!
# Also notice the mount flags to cache dependencies!
RUN --mount=type=cache,target=/app/target --mount=type=cache,target=/usr/local/cargo/registry cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . . 
RUN --mount=type=cache,target=/app/target --mount=type=cache,target=/usr/local/cargo/registry cargo build --release --target x86_64-unknown-linux-musl

# Copy the build artifacts into a non cached folder
RUN mkdir build
RUN --mount=type=cache,target=/app/target --mount=type=cache,target=/usr/local/cargo/registry cp /app/target/x86_64-unknown-linux-musl/release/taka_the_discord_bot ./build/taka_the_discord_bot_client
RUN --mount=type=cache,target=/app/target --mount=type=cache,target=/usr/local/cargo/registry cp /app/target/x86_64-unknown-linux-musl/release/tetrio_html_server ./build/taka_the_discord_bot_tetrio_html_server
RUN --mount=type=cache,target=/app/target --mount=type=cache,target=/usr/local/cargo/registry cp /app/target/x86_64-unknown-linux-musl/release/taka_the_discord_bot_status ./build/taka_the_discord_bot_status
