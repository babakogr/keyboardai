const axios = require('axios');
const { PROMPTS, LANGUAGE_CODES, DEEPL_LANGUAGE_MAP } = require('./prompts');
const { getFromCache, setInCache } = require('./cache');

const XAI_API_URL = 'https://api.x.ai/v1/chat/completions';
const XAI_API_KEY = process.env.XAI_API_KEY;
const XAI_MODEL = 'grok-4-1-fast-reasoning';

const DEEPL_API_URL = 'https://api-free.deepl.com/v2/translate';
const DEEPL_API_KEY = process.env.DEEPL_API_KEY;

const MAX_INPUT_LENGTH = 500;
const XAI_TIMEOUT = 15000;
const DEEPL_TIMEOUT = 10000;

// Validate and sanitize input text
function sanitizeInput(text) {
  if (!text || typeof text !== 'string') {
    throw new Error('Text is required');
  }
  const trimmed = text.trim();
  if (trimmed.length === 0) {
    throw new Error('Text cannot be empty');
  }
  if (trimmed.length > MAX_INPUT_LENGTH) {
    throw new Error(`Text exceeds maximum length of ${MAX_INPUT_LENGTH} characters`);
  }
  return trimmed;
}

// Call xAI (Grok) API
async function callXAI(systemPrompt, userPrompt, maxTokens = 150) {
  try {
    const response = await axios.post(
      XAI_API_URL,
      {
        model: XAI_MODEL,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        max_tokens: maxTokens,
        temperature: 0.7,
        stream: false
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${XAI_API_KEY}`
        },
        timeout: XAI_TIMEOUT
      }
    );

    const content = response.data?.choices?.[0]?.message?.content;
    if (!content) {
      throw new Error('Empty response from AI');
    }
    return content.trim();
  } catch (err) {
    if (err.response?.status === 429) {
      throw new Error('AI service rate limited. Please try again shortly.');
    }
    if (err.code === 'ECONNABORTED') {
      throw new Error('AI service timeout. Please try again.');
    }
    throw new Error(`AI service error: ${err.message}`);
  }
}

// Call DeepL API for translation
async function callDeepL(text, targetLang) {
  try {
    const deeplLang = DEEPL_LANGUAGE_MAP[targetLang] || targetLang;

    const response = await axios.post(
      DEEPL_API_URL,
      new URLSearchParams({
        text: text,
        target_lang: deeplLang
      }).toString(),
      {
        headers: {
          'Authorization': `DeepL-Auth-Key ${DEEPL_API_KEY}`,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        timeout: DEEPL_TIMEOUT
      }
    );

    const translated = response.data?.translations?.[0]?.text;
    if (!translated) {
      throw new Error('Empty translation response');
    }
    return {
      text: translated,
      detectedLang: response.data.translations[0].detected_source_language,
      provider: 'deepl'
    };
  } catch (err) {
    console.warn('[DeepL] Failed, falling back to xAI:', err.message);
    return null; // Signal to use fallback
  }
}

// TRANSLATE: DeepL primary, xAI fallback
async function translate(text, targetLang) {
  const sanitized = sanitizeInput(text);

  if (!targetLang || !LANGUAGE_CODES[targetLang]) {
    throw new Error('Invalid target language');
  }

  // Check cache
  const cached = getFromCache('translate', sanitized, targetLang);
  if (cached) return { ...cached, fromCache: true };

  // Try DeepL first
  const deeplResult = await callDeepL(sanitized, targetLang);
  if (deeplResult) {
    const result = {
      result: deeplResult.text,
      detectedLang: deeplResult.detectedLang,
      provider: 'deepl'
    };
    setInCache('translate', sanitized, targetLang, result);
    return result;
  }

  // Fallback to xAI
  const prompt = PROMPTS.translate(sanitized, LANGUAGE_CODES[targetLang]);
  const xaiResult = await callXAI(prompt.system, prompt.user, 200);
  const result = { result: xaiResult, provider: 'xai' };
  setInCache('translate', sanitized, targetLang, result);
  return result;
}

// IMPROVE: Rewrite text
async function improve(text) {
  const sanitized = sanitizeInput(text);

  const cached = getFromCache('improve', sanitized);
  if (cached) return { ...cached, fromCache: true };

  const prompt = PROMPTS.improve(sanitized);
  const result = await callXAI(prompt.system, prompt.user, 200);
  const response = { result };
  setInCache('improve', sanitized, null, response);
  return response;
}

// FIX: Grammar correction
async function fix(text) {
  const sanitized = sanitizeInput(text);

  const cached = getFromCache('fix', sanitized);
  if (cached) return { ...cached, fromCache: true };

  const prompt = PROMPTS.fix(sanitized);
  const result = await callXAI(prompt.system, prompt.user, 200);
  const response = { result };
  setInCache('fix', sanitized, null, response);
  return response;
}

// REPLY: Generate 3 reply options
async function reply(text) {
  const sanitized = sanitizeInput(text);

  const cached = getFromCache('reply', sanitized);
  if (cached) return { ...cached, fromCache: true };

  const prompt = PROMPTS.reply(sanitized);
  const result = await callXAI(prompt.system, prompt.user, 150);

  const replies = result
    .split('\n')
    .map(r => r.trim())
    .filter(r => r.length > 0 && r.length < 100)
    .slice(0, 3);

  if (replies.length === 0) {
    throw new Error('Failed to generate replies');
  }

  const response = { replies };
  setInCache('reply', sanitized, null, response);
  return response;
}

// SUGGESTIONS: Quick reply chips
async function suggestions(text) {
  const sanitized = sanitizeInput(text);

  const cached = getFromCache('suggestions', sanitized);
  if (cached) return { ...cached, fromCache: true };

  const prompt = PROMPTS.suggestions(sanitized);
  const result = await callXAI(prompt.system, prompt.user, 100);

  const chips = result
    .split('\n')
    .map(s => s.trim())
    .filter(s => s.length > 0 && s.length < 30)
    .slice(0, 5);

  if (chips.length === 0) {
    // Provide fallback suggestions
    return { suggestions: ['Okay', 'Sure!', 'Sounds good', 'Got it', '👍'] };
  }

  const response = { suggestions: chips };
  setInCache('suggestions', sanitized, null, response);
  return response;
}

module.exports = { translate, improve, fix, reply, suggestions };
