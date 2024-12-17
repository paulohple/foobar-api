# Stage 1: Build the Go application
FROM golang:1.20 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go modules and source code
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build the Go binary with explicit target OS and architecture
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o foobar-api .

# Stage 2: Use Debian Slim as runtime
FROM debian:bullseye-slim

# Install certificates for HTTPS (optional, if needed)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the runtime container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/foobar-api .

# Ensure the binary has the correct permissions
RUN chmod +x ./foobar-api

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["./foobar-api"]
