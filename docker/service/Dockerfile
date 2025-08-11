# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Production stage
FROM node:18-alpine

# Install tini for proper signal handling
RUN apk add --no-cache tini

# Create non-root user
RUN addgroup -g 1001 spectra && \
    adduser -D -u 1001 -G spectra spectra

# Set working directory
WORKDIR /app

# Copy from builder
COPY --from=builder --chown=spectra:spectra /app ./

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080

# Switch to non-root user
USER spectra

# Expose port
EXPOSE 8080

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Run the application
CMD ["node", "server.js"]
