const router = require('express').Router();
const userController = require('../controllers/user.controller');

router.post('/userResgistration',userController.register);
router.post('/findUser',userController.findUser);
router.post('/deleteUser',userController.deleteUser);
router.post('/loginUser',userController.loginUser);
router.post('/fetchAllUsers',userController.fetchAllUsers);

module.exports = router;