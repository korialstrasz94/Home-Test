FROM golang:1.20-bullseye AS builder
WORKDIR /src

COPY rest_1.0_linux_amd64 /rest-app
RUN chmod +x /rest-app

FROM gcr.io/distroless/base-debian11
COPY --from=builder /rest-app /rest-app
EXPOSE 8080
ENTRYPOINT ["/rest-app"]
