FROM golang:1.8 as build
MAINTAINER mbrooks

RUN apt-get update && \
    apt-get install -y pkg-config libsystemd-dev git gcc curl && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /go/src/github.com/mheese/journalbeat && mkdir -p /data
COPY . /go/src/github.com/mheese/journalbeat
WORKDIR /go/src/github.com/mheese/journalbeat
RUN go build

FROM debian:jessie
MAINTAINER mbrooks

RUN mkdir -p /data

WORKDIR /
COPY --from=build /go/src/github.com/mheese/journalbeat/journalbeat ./
COPY journalbeat.yml ./

CMD ["./journalbeat", "-e", "-c", "journalbeat.yml"]
