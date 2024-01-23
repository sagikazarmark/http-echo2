FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.3.0@sha256:904fe94f236d36d65aeb5a2462f88f2c537b8360475f6342e7599194f291fb7e AS xx

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


FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a

RUN apk add --update --no-cache ca-certificates tzdata bash curl

SHELL ["/bin/bash", "-c"]

COPY --from=builder /usr/local/bin/http-echo2 /usr/local/bin/

EXPOSE 8080

CMD http-echo2
