const express = require('express');
const router = express.Router();
const floorPlanController = require('../controllers/floorPlanController');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

router.post('/upload', upload.single('image'), floorPlanController.uploadFloorPlan);
router.get('/', floorPlanController.getFloorPlans);
router.get('/latest', floorPlanController.getLatestFloorPlan);

module.exports = router;
