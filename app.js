module.exports = (apis) => {
  const queue = require('./queue')(apis.request);
  const api = require('./api')(apis.request);

  const task = require('./task')(queue, api);
  const worker = require('./worker')(apis.redis, task);

  worker.start();
};
