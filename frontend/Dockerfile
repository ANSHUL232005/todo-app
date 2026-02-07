# Frontend Dockerfile - React + Vite multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with openssl-legacy-provider for better compat
# Use npm install with --force to ensure optional dependencies are installed
RUN npm install --legacy-peer-deps --force

# Copy source code
COPY . .

# Build the application with vite only (skip electron-builder)
RUN npx vite build

# Production stage - serve with Node
FROM node:20-alpine

WORKDIR /app

# Install serve to run the production build
RUN npm install -g serve

# Copy built assets from builder
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

# Run the application
CMD ["serve", "-s", "dist", "-l", "3000"]
