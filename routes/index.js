var Endpoint = require('../models/endpoint.js')
  , ServiceRequest = require('../models/servicerequest.js');


var Endpoints = require('../lib/endpoints');

var async       = require('async');


module.exports = function(req, res) {
  var endpointsData
    , serviceRequestsData;

  async.parallel([
    function(done) {
      Endpoint.find()
              .sort('endpoint', 1)
              .run(function(err, endpoints) {

        endpointsData = endpoints.map(function(endpoint) {
          return endpoint.toObject();
        });
        done();
      });
    },
    function(done) {
      ServiceRequest.find()
                    .where('requested_datetime').lte(new Date((new Date()).getTime() - 24*60*60*1000))
                    .limit(50)
                    .sort('requested_datetime', -1)
                    .run(function(err, serviceRequests) {

        serviceRequestsData = serviceRequests.map(function(serviceRequest) {
          return serviceRequest.toObject();
        });
        done();
      });
    }
  ],
  function(err) {
    res.render('index', { 
        title: 'Open311 Status'
      , endpoints: endpointsData
      , serviceRequests: serviceRequestsData
    });
  });
}