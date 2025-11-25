const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MeetingRoom = sequelize.define('MeetingRoom', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    capacity: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    floor_plan_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    x_coord: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    y_coord: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    amenities: {
        type: DataTypes.STRING,
        allowNull: true,
    }
});

module.exports = MeetingRoom;
