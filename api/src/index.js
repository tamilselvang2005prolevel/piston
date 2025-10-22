#!/usr/bin/env node
// Modern Piston index.js with runtime auto-download + CORS fix

const Logger = require('logplease');
const express = require('express');
const expressWs = require('express-ws');
const path = require('path');
const fs = require('fs/promises');
const fss = require('fs');
const bodyParser = require('body-parser');
const cors = require('cors');
const config = require('./config');
const globals = require('./globals');
const runtime = require('./runtime');

const logger = Logger.create('index');
const app = express();
expressWs(app);

// ✅ Allow all CORS requests (for your Vercel frontend)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type']
}));

(async () => {
  logger.info('Setting loglevel to', config.log_level);
  Logger.setLogLevel(config.log_level);

  logger.info('📁 Ensuring data directories exist...');
  for (const dir of Object.values(globals.data_directories)) {
    const dataPath = path.join(config.data_directory, dir);
    if (!fss.existsSync(dataPath)) {
      logger.info(`Creating ${dataPath}...`);
      fss.mkdirSync(dataPath, { recursive: true });
    }
  }

  const pkgDir = path.join(config.data_directory, globals.data_directories.packages);

  // ✅ Create /packages if missing
  if (!fss.existsSync(pkgDir)) {
    logger.warn(`⚠️ ${pkgDir} missing. Creating empty packages folder...`);
    fss.mkdirSync(pkgDir, { recursive: true });
  }

  logger.info('📦 Loading available runtimes...');
  let installedLanguages = [];

  try {
    const pkgList = await fs.readdir(pkgDir);
    const langs = await Promise.all(pkgList.map(async (lang) => {
      const langPath = path.join(pkgDir, lang);
      return await fs.readdir(langPath).then(
        (versions) => versions.map((v) => path.join(langPath, v))
      );
    }));

    installedLanguages = langs
      .flat()
      .filter((pkg) => fss.existsSync(path.join(pkg, globals.pkg_installed_file)));

    installedLanguages.forEach((pkg) => runtime.load_package(pkg));
  } catch (e) {
    logger.warn('⚠️ No installed packages found yet. Dynamic download will be used.');
  }

  // ✅ Setup Express middleware
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  // ✅ Register routes
  const apiV2 = require('./api/v2');
  app.use('/api/v2', apiV2);

  app.get('/', (req, res) => {
    const { version } = require('../package.json');
    res.status(200).send({ message: `Piston v${version} running` });
  });

  app.use((req, res) => {
    res.status(404).send({ message: 'Not Found' });
  });

  // ✅ Start the API
  const [address, port] = config.bind_address.split(':');
  const server = app.listen(port, address, () => {
    logger.info(`✅ Piston API server started on ${config.bind_address}`);
  });

  process.on('SIGTERM', () => {
    logger.info('Received SIGTERM, shutting down...');
    server.close(() => process.exit(0));
  });
})();
