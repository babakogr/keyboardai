const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET;
const TOKEN_EXPIRY = '30d';

// POST /api/auth/register - Register device and get JWT
router.post('/register', (req, res) => {
  try {
    const { deviceId, bundleId } = req.body;

    if (!deviceId || typeof deviceId !== 'string' || deviceId.length < 10 || deviceId.length > 200) {
      return res.status(400).json({ error: 'Invalid device ID' });
    }

    // Sanitize deviceId - only allow alphanumeric, hyphens, underscores
    const sanitized = deviceId.replace(/[^a-zA-Z0-9\-_]/g, '');
    if (sanitized !== deviceId) {
      return res.status(400).json({ error: 'Device ID contains invalid characters' });
    }

    const token = jwt.sign(
      {
        deviceId: sanitized,
        tier: 'free',
        bundleId: bundleId || 'com.keyboardai.app'
      },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRY }
    );

    res.json({
      token,
      tier: 'free',
      expiresIn: TOKEN_EXPIRY,
      dailyLimit: parseInt(process.env.RATE_LIMIT_FREE_DAILY) || 3
    });
  } catch (err) {
    console.error('[AUTH] Registration error:', err.message);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// POST /api/auth/refresh - Refresh JWT token
router.post('/refresh', (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing token' });
    }

    const oldToken = authHeader.split(' ')[1];

    // Verify even if expired (within 7-day grace period)
    let decoded;
    try {
      decoded = jwt.verify(oldToken, JWT_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        decoded = jwt.decode(oldToken);
        // Check if within 7-day grace period
        const expiredAt = decoded.exp * 1000;
        const gracePeriod = 7 * 24 * 60 * 60 * 1000;
        if (Date.now() - expiredAt > gracePeriod) {
          return res.status(401).json({ error: 'Token too old. Re-register required.' });
        }
      } else {
        return res.status(401).json({ error: 'Invalid token' });
      }
    }

    const newToken = jwt.sign(
      {
        deviceId: decoded.deviceId,
        tier: decoded.tier || 'free',
        bundleId: decoded.bundleId
      },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRY }
    );

    res.json({
      token: newToken,
      tier: decoded.tier || 'free',
      expiresIn: TOKEN_EXPIRY
    });
  } catch (err) {
    console.error('[AUTH] Refresh error:', err.message);
    res.status(500).json({ error: 'Token refresh failed' });
  }
});

// POST /api/auth/upgrade - Upgrade user tier (called after purchase verification)
router.post('/upgrade', (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing token' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    const { receipt, tier } = req.body;

    if (!tier || !['pro', 'free'].includes(tier)) {
      return res.status(400).json({ error: 'Invalid tier' });
    }

    // In production: verify Apple receipt here before upgrading
    // For now, trust the client (receipt validation should be added)

    const newToken = jwt.sign(
      {
        deviceId: decoded.deviceId,
        tier: tier,
        bundleId: decoded.bundleId
      },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRY }
    );

    res.json({
      token: newToken,
      tier: tier,
      expiresIn: TOKEN_EXPIRY
    });
  } catch (err) {
    console.error('[AUTH] Upgrade error:', err.message);
    res.status(500).json({ error: 'Upgrade failed' });
  }
});

module.exports = router;
