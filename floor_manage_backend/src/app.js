const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sequelize = require('./config/database');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const floorPlanRoutes = require('./routes/floorPlanRoutes');
const meetingRoomRoutes = require('./routes/meetingRoomRoutes');

require('./models');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/floor-plans', floorPlanRoutes);
app.use('/api/meeting-rooms', meetingRoomRoutes);
//jhjhjhjhjhjhjhjhjjhjhj
// Test route
app.get('/', (req, res) => {
    res.send('Floor Management API is running');
});

sequelize.sync() 
    .then(() => {
        console.log('Database synced');
    })
    .catch((err) => {
        console.error('Unable to sync database:', err);
    });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
