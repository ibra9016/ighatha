const router = require('express').Router();
const requestController = require('../controllers/centerRequest.controller');
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

router.post("/createRequest",upload.single('permit'),requestController.createRequest);
router.post("/fetchRequests",requestController.fetchRequests);
router.post("/acceptRequest",requestController.acceptRequest);
router.post("/rejectRequest",requestController.rejectRequest);

module.exports = router;