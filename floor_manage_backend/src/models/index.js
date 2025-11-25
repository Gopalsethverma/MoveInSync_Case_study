const sequelize = require('../config/database');
const { Sequelize } = require('sequelize');
const User = require('./User');
const FloorPlan = require('./FloorPlan');
const MeetingRoom = require('./MeetingRoom');
const Booking = require('./Booking');

// Associations
User.hasMany(Booking, { foreignKey: 'user_id' });
Booking.belongsTo(User, { foreignKey: 'user_id' });

FloorPlan.hasMany(MeetingRoom, { foreignKey: 'floor_plan_id' });
MeetingRoom.belongsTo(FloorPlan, { foreignKey: 'floor_plan_id' });

MeetingRoom.hasMany(Booking, { foreignKey: 'room_id' });
Booking.belongsTo(MeetingRoom, { foreignKey: 'room_id' });

module.exports = {
    sequelize,
    Sequelize,
    User,
    FloorPlan,
    MeetingRoom,
    Booking,
};
