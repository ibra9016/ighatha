const router = require('express').Router();
const centerController = require('../controllers/center.controller');
router.post('/centreResgistration',centerController.register);
module.exports = router;