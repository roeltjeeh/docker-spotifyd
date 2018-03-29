FROM rust:stretch as build

ARG pulseaudio=pulseaudio_backend

WORKDIR /usr/src/spotifyd
COPY . .

RUN apt-get -yqq update && apt-get install --no-install-recommends -yqq libasound2-dev

RUN cargo build --release --feature "${pulseaudio}"

FROM debian:stretch-slim as release

CMD ["/usr/bin/spotifyd", "--no-daemon"]

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends libasound2 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify

COPY --from=build /usr/src/spotifyd/target/release/spotifyd /usr/bin/

USER spotify

