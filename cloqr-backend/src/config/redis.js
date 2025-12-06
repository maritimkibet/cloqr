const redis = require('redis');

// Support REDIS_URL (Render, Heroku) or individual env vars (local, Google Cloud)
let client;

if (process.env.REDIS_URL) {
  // Use REDIS_URL (Render, Heroku format)
  client = redis.createClient({
    url: process.env.REDIS_URL,
    socket: {
      tls: process.env.NODE_ENV === 'production',
      rejectUnauthorized: false,
    }
  });
} else {
  // Use individual env vars (local, Google Cloud, Upstash)
  const redisConfig = {
    socket: {
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT) || 6379,
    }
  };

  // Add password if provided
  if (process.env.REDIS_PASSWORD) {
    redisConfig.password = process.env.REDIS_PASSWORD;
  }

  // Enable TLS if specified or in production with external Redis
  if (process.env.REDIS_TLS === 'true' || (process.env.NODE_ENV === 'production' && process.env.REDIS_HOST && process.env.REDIS_HOST !== 'localhost')) {
    redisConfig.socket.tls = true;
    redisConfig.socket.rejectUnauthorized = false;
  }

  client = redis.createClient(redisConfig);
}

client.on('connect', () => {
  console.log('✅ Redis connected');
});

client.on('error', (err) => {
  console.error('❌ Redis error:', err);
});

client.connect();

module.exports = client;
