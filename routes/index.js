var RequestsPing = require('../models/requestsping.js')
  , ServicesPing = require('../models/servicesping.js');

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
    console.log(endpointData);
    res.render('index', { 
      title: 'Open311 Status'
    , endpoints: endpointData
    });
  });
}