const missionController = require('../controllers/mission.controller');
const router = require('express').Router();

router.post("/createMission",missionController.createMission);
router.post("/getMission",missionController.missionDetails);
router.post("/changeStatus",missionController.changeStatus);

module.exports = router;