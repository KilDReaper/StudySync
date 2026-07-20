const { spawn } = require('child_process');
const net = require('net');
const path = require('path');
const fs = require('fs');

let mongoProcess = null;

const checkPort = (port, host) => {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    const onError = () => {
      socket.destroy();
      resolve(false);
    };
    socket.setTimeout(1000);
    socket.once('error', onError);
    socket.once('timeout', onError);
    socket.connect(port, host, () => {
      socket.end();
      resolve(true);
    });
  });
};

const startLocalMongo = async () => {
  const uri = process.env.MONGODB_URI || '';
  // Only handle local Mongo if URI points to localhost or 127.0.0.1
  if (!uri.includes('localhost') && !uri.includes('127.0.0.1')) {
    return;
  }

  const port = 27017;
  const host = '127.0.0.1';

  const isRunning = await checkPort(port, host);
  if (isRunning) {
    return;
  }

  // eslint-disable-next-line no-console
  console.log('Local MongoDB is not running. Starting it programmatically...');

  const mongoPath = process.env.MONGODB_PATH || 'C:\\Program Files\\MongoDB\\Server\\8.3\\bin\\mongod.exe';
  const dbPath = process.env.MONGODB_DBPATH || path.join(__dirname, '..', '..', 'data', 'db');

  if (!fs.existsSync(dbPath)) {
    fs.mkdirSync(dbPath, { recursive: true });
  }

  mongoProcess = spawn(mongoPath, [
    '--dbpath', dbPath,
    '--port', String(port),
  ], {
    detached: false,
    stdio: 'ignore',
  });

  const cleanUp = () => {
    if (mongoProcess) {
      try {
        mongoProcess.kill();
      } catch (err) {
        // already dead
      }
      mongoProcess = null;
    }
  };

  process.on('exit', cleanUp);
  process.on('SIGINT', () => {
    cleanUp();
    process.exit(0);
  });
  process.on('SIGTERM', () => {
    cleanUp();
    process.exit(0);
  });
  process.once('SIGUSR2', () => {
    cleanUp();
    process.kill(process.pid, 'SIGUSR2');
  });

  let attempts = 0;
  while (attempts < 10) {
    await new Promise((resolve) => setTimeout(resolve, 500));
    const active = await checkPort(port, host);
    if (active) {
      // eslint-disable-next-line no-console
      console.log('Local MongoDB database started successfully.');
      return;
    }
    attempts++;
  }

  throw new Error('Failed to start local MongoDB server automatically.');
};

module.exports = startLocalMongo;
