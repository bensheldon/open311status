var request     = require('request')
  , querystring = require('querystring')
  , parser      = require('xml2json')


var Endpoints = require('../lib/endpoints');

var Pinger = require('../lib/pinger')
  , pinger = new Pinger(Endpoints);

module.exports = function(req, routeRes) {
  var city = req.params.endpoint;

  if( Endpoints[city] ) {
    var servicesUrl = pinger.formatEndpoint(Endpoints[city], 'services');

    request.get(servicesUrl, function (err, res, body) {
      if (res.statusCode == 200) {
        if (Endpoints[city].format == 'xml') {
          try {
            var resServices = (parser.toJson(body, {object: true})).services.service;
          }
          catch(err) {
            var resServices = {error: body };
          }
        }
        else {
          try {
            var resServices = JSON.parse(body);
          }
          catch(err) {
            var resServices = {error: body };
          }
        }
      }
      routeRes.render('services', {
        layout: false
      , endpoint: city
      , services: resServices
      });
    });
  }
  else {
    res.render('services', {
      endpoint: city
    , services: {error: "That is not an endpoint!"}
    });
  }
}
