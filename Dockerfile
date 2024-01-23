FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.2.1@sha256:8879a398dedf0aadaacfbd332b29ff2f84bc39ae6d4e9c0a1109db27ac5ba012 AS xx

FROM --platform=$BUILDPLATFORM golang:1.20.4-alpine3.16@sha256:6469405d7297f82d56195c90a3270b0806ef4bd897aa0628477d9959ab97a577 AS builder

COPY --from=xx / /

RUN apk add --update --no-cache ca-certificates make git curl clang lld

ARG TARGETPLATFORM

RUN xx-apk --update --no-cache add musl-dev gcc

RUN xx-go --wrap

WORKDIR /usr/local/src/http-echo2

ARG GOPROXY

ENV CGO_ENABLED=0

COPY go.mod ./
RUN go mod download

COPY . .

RUN go build -o /usr/local/bin/http-echo2 .
RUN xx-verify /usr/local/bin/http-echo2


FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48

RUN apk add --update --no-cache ca-certificates tzdata bash curl

SHELL ["/bin/bash", "-c"]

COPY --from=builder /usr/local/bin/http-echo2 /usr/local/bin/

EXPOSE 8080

CMD http-echo2
