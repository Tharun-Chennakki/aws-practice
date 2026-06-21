# Multi-stage build for tests
FROM mcr.microsoft.com/playwright:v1.40.0-jammy as test-stage

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY playwright.config.ts ./

# Install dependencies
RUN npm ci

# Copy app and tests
COPY . .

# Run tests
RUN npx playwright install

# Production stage - serve the app
FROM node:20-alpine

WORKDIR /app

# Install http-server globally
RUN npm install -g http-server

# Copy only necessary files for running the app
COPY index.html .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start the server
CMD ["http-server", ".", "-p", "3000", "-c-1"]
