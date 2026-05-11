const { Router } = require('express');
const controller = require('./reservas.controller');

const router = Router();

router.get('/', controller.list);
router.get('/:id', controller.getById);
router.post('/', controller.create);
router.put('/:id/status', controller.updateStatus);

module.exports = router;
