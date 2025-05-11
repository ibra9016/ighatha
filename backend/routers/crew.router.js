const crewController = require('../controllers/crew.controller');
const router = require('express').Router();

router.post("/registerCrew",crewController.register)
router.post('/fetchCrew',crewController.fetchCrew)
router.post('/deleteMember',crewController.deleteMember)

module.exports = router;

