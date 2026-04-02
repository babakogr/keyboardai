const express = require('express');
const router = express.Router();
const aiService = require('../services/ai');

// POST /api/ai/translate
router.post('/translate', async (req, res) => {
  try {
    const { text, targetLang } = req.body;
    if (!text || !targetLang) {
      return res.status(400).json({ error: 'text and targetLang are required' });
    }
    const result = await aiService.translate(text, targetLang.toUpperCase());
    res.json(result);
  } catch (err) {
    console.error('[AI/translate]', err.message);
    res.status(err.message.includes('Invalid') ? 400 : 500).json({ error: err.message });
  }
});

// POST /api/ai/improve
router.post('/improve', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }
    const result = await aiService.improve(text);
    res.json(result);
  } catch (err) {
    console.error('[AI/improve]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/ai/fix
router.post('/fix', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }
    const result = await aiService.fix(text);
    res.json(result);
  } catch (err) {
    console.error('[AI/fix]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/ai/reply
router.post('/reply', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }
    const result = await aiService.reply(text);
    res.json(result);
  } catch (err) {
    console.error('[AI/reply]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/ai/suggestions
router.post('/suggestions', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }
    const result = await aiService.suggestions(text);
    res.json(result);
  } catch (err) {
    console.error('[AI/suggestions]', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
