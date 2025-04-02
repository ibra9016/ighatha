const router = require('express').Router();
const userController = require('../controllers/user.controller');

router.post('/userResgistration',userController.register);

module.exports = router;