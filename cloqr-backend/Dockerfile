FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create uploads directory
RUN mkdir -p uploads

# Expose port (Cloud Run uses PORT env variable)
EXPOSE 8080

# Start server
CMD ["node", "src/server.js"]
