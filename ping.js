var mongoose = require('mongoose')

var Pinger = require('./lib/pinger');
var Endpoint = require('./models/endpoint.js');
var Endpoints = require('./lib/endpoints');
var pinger = new Pinger(Endpoints);

mongoose.connect(process.env.MONGOHQ);
Endpoint.generateAll(function(err, endpoints) {
  if (err) {
    return console.log(err);
  }

  console.log('Loaded ' + endpoints.length +' endpoints');
  pinger.pingAll(function(err) {
    if (err) {
      console.log(err);
    }
  }, null, true);
});
