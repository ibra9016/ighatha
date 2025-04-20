const router = require('express').Router();
const postController = require("../controllers/post.controller");
const multer = require('multer');
const { post } = require('./user.router');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
      // Create the uploads folder dynamically
      const folder = 'uploads';
      cb(null, folder);
    },
    filename: (req, file, cb) => {
      // Set filename as the current timestamp plus original name
      cb(null, Date.now() + '-' + file.originalname);
    }
  });
  
  const upload = multer({ storage });
  
  // POST /api/upload
  router.post('/postRegistration', upload.single('photo'), postController.register);
  router.post('/getPics',postController.getPics);
module.exports = router;