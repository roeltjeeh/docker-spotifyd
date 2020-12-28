FROM rust:1.47-buster as build

ARG BRANCH=master
ARG COMMIT=39106ed8ed270247b1203cc2eed5b05121c90cf7

WORKDIR /usr/src/spotifyd

RUN apt-get -yqq update && \
    apt-get install --no-install-recommends -yqq libasound2-dev && \
    git clone --branch=${BRANCH} https://github.com/Spotifyd/spotifyd.git . && \
    git checkout -b working ${COMMIT} 

RUN cargo build --release

FROM debian:buster-slim as release

CMD ["/usr/bin/spotifyd", "--no-daemon"]

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends libasound2 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify

COPY --from=build /usr/src/spotifyd/target/release/spotifyd /usr/bin/

USER spotify

