const router = require('express').Router();
const vehiculeController = require('../controllers/vehicule.controller');

router.post('/vehiculeRegistration',vehiculeController.register);

module.exports = router;