# Stage 1: Build the Go application
FROM golang:1.20 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o foobar-api .

# Stage 2: Create a smaller image for runtime
FROM alpine:latest

# Install certificates for HTTPS (optional, if needed)
RUN apk --no-cache add ca-certificates

# Set the working directory inside the runtime container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/foobar-api .

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["./foobar-api"]
