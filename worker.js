const async = require('async');

module.exports = (redis, task) => {
  const CHANNEL = 'tasks';

  let halted = false;

  function halt() {
    halted = true;
    console.info('Task processing halted; waiting for events.');
  }

  function resume() {
    halted = false;
    console.info('Task processing resumed.');
  }

  function start() {
    redis.on('message', (chan, msg) => {
      if (chan != CHANNEL) return;

      if (isHalted()) {
        resume();
        doTasks();
      }
    });

    redis.subscribe(CHANNEL);

    doTasks();
  }

  function isHalted() {
    return halted === true;
  }

  function isWorking() {
    return halted === false;
  }

  function doTasks() {
    async.whilst(
      () => isWorking(),
      (cb) => task.next((err, res) => {
        if (err) return cb(err);

        if (res.empty) halt()

        cb(null, res);
      }),
      (err) => {
        if (err) console.error(err);
      }
    );
  }

  return {
    start
  };
};
