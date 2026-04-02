const { LRUCache } = require('lru-cache');

const FREE_DAILY_LIMIT = parseInt(process.env.RATE_LIMIT_FREE_DAILY) || 3;
const PRO_PER_MINUTE = parseInt(process.env.RATE_LIMIT_PRO_PER_MINUTE) || 30;

// Track free user daily usage: deviceId -> { count, resetDate }
const freeUsageCache = new LRUCache({
  max: 100000,
  ttl: 24 * 60 * 60 * 1000 // 24 hours
});

// Track pro user per-minute usage
const proUsageCache = new LRUCache({
  max: 50000,
  ttl: 60 * 1000 // 1 minute
});

function getTodayKey() {
  return new Date().toISOString().split('T')[0];
}

function usageMiddleware(req, res, next) {
  const { deviceId, tier } = req.user;
  const today = getTodayKey();

  if (tier === 'pro') {
    const proKey = `pro:${deviceId}`;
    const currentMinuteCount = proUsageCache.get(proKey) || 0;

    if (currentMinuteCount >= PRO_PER_MINUTE) {
      return res.status(429).json({
        error: 'Pro rate limit exceeded. Please wait a moment.',
        retryAfter: 60
      });
    }

    proUsageCache.set(proKey, currentMinuteCount + 1);

    res.setHeader('X-RateLimit-Limit', PRO_PER_MINUTE);
    res.setHeader('X-RateLimit-Remaining', PRO_PER_MINUTE - currentMinuteCount - 1);
    return next();
  }

  // Free tier
  const freeKey = `free:${deviceId}:${today}`;
  const currentDayCount = freeUsageCache.get(freeKey) || 0;

  if (currentDayCount >= FREE_DAILY_LIMIT) {
    return res.status(429).json({
      error: 'Daily free limit reached. Upgrade to Pro for unlimited access.',
      code: 'FREE_LIMIT_REACHED',
      limit: FREE_DAILY_LIMIT,
      used: currentDayCount,
      resetAt: new Date(new Date(today).getTime() + 24 * 60 * 60 * 1000).toISOString()
    });
  }

  freeUsageCache.set(freeKey, currentDayCount + 1);

  res.setHeader('X-RateLimit-Limit', FREE_DAILY_LIMIT);
  res.setHeader('X-RateLimit-Remaining', FREE_DAILY_LIMIT - currentDayCount - 1);
  res.setHeader('X-Usage-Tier', 'free');

  next();
}

module.exports = usageMiddleware;
