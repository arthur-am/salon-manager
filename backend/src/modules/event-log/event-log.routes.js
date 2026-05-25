const { Router } = require('express');
const controller = require('./event-log.controller');

const router = Router();

// GET /api/event-log  — lista eventos processados pelo consumer
router.get('/', controller.list);

module.exports = router;
