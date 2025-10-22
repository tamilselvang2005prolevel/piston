const fs = require('fs');

const globals = {
    os_info: fs.readFileSync('/etc/os-release', 'utf-8'),
    data_directories: {
        packages: 'packages',
        temp: 'temp',
        jobs: 'jobs',
        cache: 'cache',
    },
    pkg_installed_file: '.installed',
};

module.exports = globals;
