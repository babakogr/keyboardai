require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const authMiddleware = require('./middleware/auth');
const usageMiddleware = require('./middleware/usage');
const aiRoutes = require('./routes/ai');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Security headers
app.use(helmet());

// CORS - restrict to your app's bundle identifier
app.use(cors({
  origin: '*',
  methods: ['POST', 'GET'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Device-ID', 'X-Bundle-ID']
}));

// Body parsing with size limit to prevent abuse
app.use(express.json({ limit: '5kb' }));

// Global rate limit: 1000 req/min across all clients
const globalLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_GLOBAL_PER_MINUTE) || 1000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Please try again later.' }
});
app.use(globalLimiter);

// Per-IP rate limit: 60 req/min per IP
const ipLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.ip,
  message: { error: 'Rate limit exceeded for your IP.' }
});
app.use('/api/', ipLimiter);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

// Auth routes (no auth middleware needed)
app.use('/api/auth', authRoutes);

// AI routes (require auth + usage tracking)
app.use('/api/ai', authMiddleware, usageMiddleware, aiRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(`[ERROR] ${new Date().toISOString()}:`, err.message);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`[KeyboardAI] Server running on port ${PORT}`);
  console.log(`[KeyboardAI] Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
