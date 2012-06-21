var ServiceRequest = require('../models/servicerequest.js');

var Endpoints = require('../lib/endpoints');

module.exports = function(req, res) {
  var city = req.params.endpoint;

  if( Endpoints[city] ) {
    ServiceRequest.find()
                  .where('endpoint', city)
                  .limit(200)
                  .sort('requested_datetime', -1)
                  .run(function(err, serviceRequests) {

      serviceRequests = serviceRequests.map(function(serviceRequest) {
        return serviceRequest.toObject();
      });

      res.render('servicerequests', {
        layout: false
      , endpoint: city
      , serviceRequests: serviceRequests
      });
    });
  }
  else {
    res.render('servicerequests', { 
      endpoint: city
    , serviceRequests: {error: "That is not an endpoint!"}
    });
  }
}