var RequestsPing = require('../models/requestsping.js')
  , ServicesPing = require('../models/servicesping.js');

var Endpoints = require('../lib/endpoints');

module.exports = function(req, res) {
  var endpointCount = Object.keys(Endpoints).length;
  
  ServicesPing.find()
              .limit(endpointCount)
              .sort('requestedAt', -1)
              .run(function(err, servicesPings) {
      
    RequestsPing.find()
                .limit(endpointCount)
                .sort('requestedAt', -1)
                .run(function(err, requestsPings) {
       
      // TODO: Find a better way to convert Mongoose docs to objects
      servicesPings = servicesPings.map(function (servicesPing) {
         return servicesPing.toObject();
      });
      requestsPings = requestsPings.map(function (requestsPing) {
         return requestsPing.toObject();
      });
          
      res.render('index', { 
          title: 'Open311 Status'
        , endpoints: Endpoints
        , servicesPings: servicesPings
        , requestsPings: requestsPings
        });
    });                             
  });
}