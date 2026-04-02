// AI Prompt Templates - Optimized for minimal token usage and natural responses

const PROMPTS = {
  translate: (text, targetLang) => ({
    system: `You are a translator. Translate the given text to ${targetLang}. Return ONLY the translated text, nothing else. Keep the same tone and style.`,
    user: text
  }),

  improve: (text) => ({
    system: 'You are a writing assistant. Rewrite the given text to be more natural, clear, and fluent. Keep the same meaning and length. Return ONLY the improved text, nothing else.',
    user: text
  }),

  fix: (text) => ({
    system: 'You are a grammar checker. Fix ONLY grammar, spelling, and punctuation errors. Do NOT change the meaning, tone, or style. If there are no errors, return the original text unchanged. Return ONLY the corrected text, nothing else.',
    user: text
  }),

  reply: (text) => ({
    system: 'You are a reply assistant. Generate exactly 3 short, natural reply options for the given message. Each reply should be different in tone (casual, professional, friendly). Format: one reply per line, no numbering, no quotes, no labels. Keep each under 15 words.',
    user: `Message to reply to: "${text}"`
  }),

  suggestions: (text) => ({
    system: 'Generate 5 very short contextual reply suggestions (2-4 words each) for the given message. Mix casual and professional tones. Include 1-2 with emojis. Format: one per line, no numbering.',
    user: `Message: "${text}"`
  })
};

const LANGUAGE_CODES = {
  'EN': 'English',
  'TR': 'Turkish',
  'DE': 'German',
  'FR': 'French',
  'ES': 'Spanish',
  'IT': 'Italian',
  'PT': 'Portuguese',
  'RU': 'Russian',
  'JA': 'Japanese',
  'KO': 'Korean',
  'ZH': 'Chinese',
  'AR': 'Arabic',
  'NL': 'Dutch',
  'PL': 'Polish'
};

const DEEPL_LANGUAGE_MAP = {
  'EN': 'EN-US',
  'TR': 'TR',
  'DE': 'DE',
  'FR': 'FR',
  'ES': 'ES',
  'IT': 'IT',
  'PT': 'PT-BR',
  'RU': 'RU',
  'JA': 'JA',
  'KO': 'KO',
  'ZH': 'ZH-HANS',
  'AR': 'AR',
  'NL': 'NL',
  'PL': 'PL'
};

module.exports = { PROMPTS, LANGUAGE_CODES, DEEPL_LANGUAGE_MAP };
