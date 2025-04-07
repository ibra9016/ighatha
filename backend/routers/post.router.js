const router = require('express').Router();
const postController = require("../controllers/post.controller");

router.post('/postRegistration',postController.register);
module.exports = router;