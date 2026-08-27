# Build the Go API as a static binary, then ship it on a minimal base image.
# Build context is ./backend (see docker-compose.yml).

FROM golang:1.25-alpine AS build

WORKDIR /src

# Download modules first so dependency layers cache independently of source.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server


FROM alpine:3.22

RUN apk add --no-cache ca-certificates \
    && adduser -D -u 10001 app

WORKDIR /app
COPY --from=build /out/server /app/server

USER app
EXPOSE 8080

ENTRYPOINT ["/app/server"]
