'use strict';

const request = require('request');
const redis = require('redis').createClient();

module.exports = () => {
  return {
    redis,
    request,
  };
};
