const { FloorPlan } = require('../models');

exports.uploadFloorPlan = async (req, res) => {
    try {
        const { version, data_json, created_by } = req.body;
        const image_url = req.file ? req.file.path.replace(/\\/g, '/') : null; 

        
        const latestPlan = await FloorPlan.findOne({
            order: [['version', 'DESC']],
        });

        let nextVersion = 1;
        if (latestPlan) {
            if (parseInt(version) <= latestPlan.version) {
                return res.status(409).json({
                    message: 'Conflict detected. A newer version exists.',
                    latestVersion: latestPlan.version,
                    yourVersion: version,
                });
            }
            nextVersion = latestPlan.version + 1;
        }

        const newPlan = await FloorPlan.create({
            version: nextVersion,
            image_url: image_url || 'placeholder.png',
            data_json,
            created_by,
        });

        res.status(201).json({ message: 'Floor plan uploaded successfully', plan: newPlan });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getFloorPlans = async (req, res) => {
    try {
        const plans = await FloorPlan.findAll({ order: [['version', 'DESC']] });
        res.json(plans);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getLatestFloorPlan = async (req, res) => {
    try {
        const plan = await FloorPlan.findOne({ order: [['version', 'DESC']] });
        if (!plan) return res.status(404).json({ message: 'No floor plans found' });
        res.json(plan);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
