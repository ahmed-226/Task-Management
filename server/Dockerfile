# Stage 1: Build dependencies
FROM node:18-alpine AS dependencies

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && npm cache clean --force


# Stage 2: Production image
FROM node:18-alpine AS production

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --from=dependencies /app/node_modules ./node_modules

COPY --chown=nodejs:nodejs . .

USER nodejs

EXPOSE 4000

# Start the application
CMD ["node", "server.js"]