const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;
const VALID_BUNDLE_IDS = [
  'com.keyboardai.app',
  'com.keyboardai.app.keyboard'
];

function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers['authorization'];
    const bundleId = req.headers['x-bundle-id'];
    const deviceId = req.headers['x-device-id'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing authorization token' });
    }

    if (!deviceId || deviceId.length < 10) {
      return res.status(401).json({ error: 'Missing or invalid device ID' });
    }

    if (bundleId && !VALID_BUNDLE_IDS.includes(bundleId)) {
      return res.status(403).json({ error: 'Invalid bundle identifier' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);

    if (decoded.deviceId !== deviceId) {
      return res.status(403).json({ error: 'Token device mismatch' });
    }

    req.user = {
      deviceId: decoded.deviceId,
      tier: decoded.tier || 'free',
      issuedAt: decoded.iat
    };

    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
    }
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    return res.status(500).json({ error: 'Authentication failed' });
  }
}

module.exports = authMiddleware;
