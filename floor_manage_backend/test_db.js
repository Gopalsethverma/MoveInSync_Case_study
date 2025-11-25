const sequelize = require('./src/config/database');

console.log('Testing database connection...');

sequelize.authenticate()
    .then(() => {
        console.log('Connection has been established successfully.');
        process.exit(0);
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
        process.exit(1);
    });
