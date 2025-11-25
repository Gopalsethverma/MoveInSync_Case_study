const { MeetingRoom, Booking, Sequelize } = require('../models');
const { Op } = Sequelize;

exports.getRooms = async (req, res) => {
    try {
        const { start_time, end_time } = req.query;
        let rooms = await MeetingRoom.findAll();

        if (start_time && end_time) {
            const availableRooms = [];
            for (const room of rooms) {
                const existingBooking = await Booking.findOne({
                    where: {
                        room_id: room.id,
                        [Op.and]: [
                            { start_time: { [Op.lt]: end_time } },
                            { end_time: { [Op.gt]: start_time } },
                        ],
                    },
                });
                if (!existingBooking) {
                    availableRooms.push(room);
                }
            }
            rooms = availableRooms;
        }

        res.json(rooms);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.bookRoom = async (req, res) => {
    try {
        const { room_id, user_id, start_time, end_time } = req.body;

        // Check availability
        const existingBooking = await Booking.findOne({
            where: {
                room_id,
                [Op.and]: [
                    {
                        start_time: {
                            [Op.lt]: end_time,
                        },
                    },
                    {
                        end_time: {
                            [Op.gt]: start_time,
                        },
                    },
                ],
            },
        });

        if (existingBooking) {
            return res.status(409).json({ message: 'Room is already booked for this time slot' });
        }

        const booking = await Booking.create({
            room_id,
            user_id,
            start_time,
            end_time,
        });

        res.status(201).json({ message: 'Room booked successfully', booking });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.recommendRoom = async (req, res) => {
    try {
        const { capacity, start_time, end_time } = req.query;

        // Find rooms with sufficient capacity
        const rooms = await MeetingRoom.findAll({
            where: {
                capacity: {
                    [Op.gte]: capacity,
                },
            },
            order: [['capacity', 'ASC']], // Best fit first
        });

        // Filter out booked rooms
        const availableRooms = [];
        for (const room of rooms) {
            const existingBooking = await Booking.findOne({
                where: {
                    room_id: room.id,
                    [Op.and]: [
                        {
                            start_time: {
                                [Op.lt]: end_time,
                            },
                        },
                        {
                            end_time: {
                                [Op.gt]: start_time,
                            },
                        },
                    ],
                },
            });

            if (!existingBooking) {
                availableRooms.push(room);
            }
        }

        // Calculate weightage based on user history
        const { user_id } = req.query;
        if (user_id) {
            const userBookings = await Booking.findAll({
                where: { user_id },
                attributes: ['room_id'],
            });

            const roomCounts = {};
            userBookings.forEach(b => {
                roomCounts[b.room_id] = (roomCounts[b.room_id] || 0) + 1;
            });

            availableRooms.sort((a, b) => {
                const weightA = roomCounts[a.id] || 0;
                const weightB = roomCounts[b.id] || 0;
                return weightB - weightA; // Descending order of weight
            });
        }

        res.json(availableRooms);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getUserBookings = async (req, res) => {
    try {
        const { user_id } = req.query;
        const bookings = await Booking.findAll({
            where: { user_id },
            include: [{ model: MeetingRoom, attributes: ['name'] }],
            order: [['start_time', 'ASC']],
        });
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
