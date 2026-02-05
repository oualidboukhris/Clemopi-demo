# Frontend Dockerfile - Multi-stage build

# Stage 1: Build the React app
FROM node:18-alpine AS builder

WORKDIR /app

# Accept build arguments
ARG REACT_APP_GOOGLE_MAPS_KEY
ARG REACT_APP_URL
ARG REACT_APP_URL_IMAGE

# Set environment variables for build
ENV REACT_APP_GOOGLE_MAPS_KEY=$REACT_APP_GOOGLE_MAPS_KEY
ENV REACT_APP_URL=$REACT_APP_URL
ENV REACT_APP_URL_IMAGE=$REACT_APP_URL_IMAGE

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built files from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx config (optional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]