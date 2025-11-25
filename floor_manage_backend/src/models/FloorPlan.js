const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const FloorPlan = sequelize.define('FloorPlan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    version: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    image_url: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    data_json: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    created_by: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
}, {
    indexes: [
        {
            unique: true,
            fields: ['version'],
        }
    ]
});

module.exports = FloorPlan;
