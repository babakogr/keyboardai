const { LRUCache } = require('lru-cache');
const crypto = require('crypto');

// Response cache: hash(action+text+lang) -> response
const responseCache = new LRUCache({
  max: 10000,
  ttl: 60 * 60 * 1000, // 1 hour TTL
  maxSize: 50 * 1024 * 1024, // 50MB max
  sizeCalculation: (value) => JSON.stringify(value).length
});

function getCacheKey(action, text, lang) {
  const input = `${action}:${text.trim().toLowerCase()}:${lang || ''}`;
  return crypto.createHash('md5').update(input).digest('hex');
}

function getFromCache(action, text, lang) {
  const key = getCacheKey(action, text, lang);
  return responseCache.get(key);
}

function setInCache(action, text, lang, response) {
  const key = getCacheKey(action, text, lang);
  responseCache.set(key, response);
}

function getCacheStats() {
  return {
    size: responseCache.size,
    maxSize: responseCache.max
  };
}

module.exports = { getFromCache, setInCache, getCacheStats };
