FROM golang:1.19.4-alpine3.16 AS builder

RUN apk add --update --no-cache ca-certificates make git curl

WORKDIR /usr/local/src/app

ARG GOPROXY

COPY go.* ./
RUN go mod download

COPY . .

RUN go build -o /usr/local/bin/http-echo2 .


FROM alpine:3.17.1

RUN apk add --update --no-cache ca-certificates tzdata bash curl

SHELL ["/bin/bash", "-c"]

COPY --from=builder /usr/local/bin/http-echo2 /usr/local/bin/

EXPOSE 8080

CMD http-echo2
