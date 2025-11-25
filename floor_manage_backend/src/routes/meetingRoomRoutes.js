const express = require('express');
const router = express.Router();
const meetingRoomController = require('../controllers/meetingRoomController');

router.get('/', meetingRoomController.getRooms);
router.post('/book', meetingRoomController.bookRoom);
router.get('/recommend', meetingRoomController.recommendRoom);

router.get('/bookings', meetingRoomController.getUserBookings);
module.exports = router;
