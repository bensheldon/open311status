
var async     = require('async')
  , Endpoints = require('../lib/endpoints');

var Endpoint = require('../models/endpoint.js')
  , ServiceRequest = require('../models/servicerequest.js');



module.exports = function(req, res) {
  var endpointsData;

  async.parallel([
    function(done) {
      Endpoint.find()
              .sort('endpoint')
              .exec(function(err, endpoints) {

        endpointsData = endpoints.map(function(endpoint) {
          return endpoint.toObject();
        });
        done();
      });
    }
  ],
  function(err) {
    res.json(endpointsData);
  });
}
