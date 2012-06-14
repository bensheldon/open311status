var RequestsPing = require('../models/requestsping.js')
  , ServicesPing = require('../models/servicesping.js')
  , ServiceRequest = require('../models/servicerequest.js');


var Endpoints = require('../lib/endpoints');

var async       = require('async');


module.exports = function(req, res) {
  var endpointData = {};
  // load up our endpoint data
  async.forEach(Object.keys(Endpoints), function(city, callback) {

    ServicesPing.find()
                .where('endpoint', city)
                .limit(1)
                .sort('requestedAt', -1)
                .run(function(err, servicesPing) {
        
      RequestsPing.find()
                  .where('endpoint', city)
                  .limit(1)
                  .sort('requestedAt', -1)
                  .run(function(err, requestsPing) {

        endpointData[city] = {
           services: servicesPing[0].toObject()
         , requests: requestsPing[0].toObject()
        }
        callback();
      });
    });
  },
  function (err) {
    var serviceRequests = ServiceRequest.find()
                                        .where('requested_datetime').lte(new Date((new Date()).getTime() - 60*60*1000))
                                        .limit(50)
                                        .sort('requested_datetime', -1)
                                        .run(function(err, serviceRequests) {

      serviceRequests = serviceRequests.map(function(serviceRequest) {
        return serviceRequest.toObject();
      });

      res.render('index', { 
        title: 'Open311 Status'
      , endpoints: endpointData
      , serviceRequests: serviceRequests
      });
    });
  });
}