const router = require('express').Router();
const vehiculeController = require('../controllers/vehicule.controller');

router.post('/vehiculeRegistration',vehiculeController.register);
router.post('/fetchVehicules',vehiculeController.fetchVehicules);
router.post('/deleteVehicle',vehiculeController.deletevehicle);


module.exports = router;