FROM --platform=${BUILDPLATFORM} golang:1.12 as builder
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0

ADD my-app.go /src/my-app.go
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -o /dist/my-app /src/my-app.go

FROM scratch

COPY --from=builder /dist/my-app /my-app

EXPOSE 8080
ENV GREETING "Hello world!"
ENTRYPOINT ["/my-app"]
