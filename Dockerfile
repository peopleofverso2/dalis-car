# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code and public assets
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM nginx:alpine

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html
COPY --from=build /app/public/favicon.ico /usr/share/nginx/html/
COPY --from=build /app/public/logo192.png /usr/share/nginx/html/
COPY --from=build /app/public/logo512.png /usr/share/nginx/html/
COPY --from=build /app/public/manifest.json /usr/share/nginx/html/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
