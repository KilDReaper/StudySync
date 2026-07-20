const dns = require('dns');
dns.setServers(['8.8.8.8', '1.1.1.1']);

require('dotenv').config();

const app = require('./app');
const connectDB = require('./config/db');
const startLocalMongo = require('./config/localMongo');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await startLocalMongo();
  await connectDB();

  app.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`StudySync API running on port ${PORT}`);
  });
};

startServer().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
