var request     = require('request')
  , querystring = require('querystring')
  , parser      = require('xml2json')
  , async       = require('async');
  
var RequestsPing = require('../models/RequestsPing.js')
  , ServicesPing = require('../models/ServicesPing.js');

var Fetcher = function(endpoints) {
  this.endpoints = endpoints;
};

Fetcher.prototype = {
  
  formatEndpoint: function(endpoint, method, params) {
    var url    = ''
      , format = endpoint.format || 'json';
    
    params = params || {};
    
    if(endpoint.jurisdiction) {
      params.jurisdiction_id = endpoint.jurisdiction;
    }
    
    // add a trailing slash
    if (endpoint.endpoint.slice(-1) !== '/') {
      url = endpoint.endpoint + '/';
    }
    else {
      url = endpoint.endpoint;
    }
    
    url =  url + method + "." + format;
    
    if (!isEmpty(params)) {
      url += "?" + querystring.stringify(params);
    }
    
    return url;
  },
  
  pingServices: function(pingCallback) {
    var self = this;
    var endpoints = this.endpoints;
    
    var ServicesPings = []; // to hold all our retreived requests
    
    async.forEachSeries(Object.keys(endpoints), function(city, callback) {     
      var servicesCount = 0;  
      var servicesUrl = self.formatEndpoint(endpoints[city], 'services');
      
      // Set a timer
      var start = new Date()
        , responseTime = 0;
      request.get(servicesUrl, function (err, res, body) {
        if (!err) {
          responseTime = new Date().getTime() - start.getTime();
          
          if (res.statusCode == 200) {
            if (endpoints[city].format == 'xml') {
              try {
                var resServices = parser.toJson(body, {object: true});
                servicesCount = resServices.services.service.length;
              }
              catch(err) {
                console.log('Could not parse Services XML for ' + city + '; ' + err);
                console.log(body);
              }
            }
            else {
              try {
                var resServices = JSON.parse(body);
                servicesCount = resServices.length;
              }
              catch(err) {
                console.log('Could not parse Services JSON for ' + city + '; ' + err);
                console.log(body);
              }
            }
          }
          
          var servicesPing = new ServicesPing({
             endpoint      : city
           , statusCode    : res.statusCode
           , responseTime  : responseTime
           , servicesCount : servicesCount
           , requestedAt   : start
          });
          servicesPing.save(function (err, servicesPing) {
            ServicesPings.push(servicesPing);
            callback(); // our async callback
          });
        }  
      });
      
    }, 
    function() {
      // Retrieved all Services!
      pingCallback(ServicesPings);
    });  
  },
  
  pingRequests: function(pingCallback) {
    var self = this;
    var endpoints = this.endpoints;
    var RequestsPings = []; // to hold all our retreived requests
    
    async.forEachSeries(Object.keys(endpoints), function(city, callback) {
      var d = new Date();
      // Search previous 15 minutes 
      // TODO: make this more exact and not relative to the request
      var params = {
        start_date: new Date(d - 15 * 1000).toISOString(),
        end_date: d.toISOString()
      };
      var requestsUrl = self.formatEndpoint(endpoints[city], 'requests', params);
      
      var requestsCount15Min = 0;  
            
      // Set a timer
      var start = new Date()
        , responseTime = 0;
      request.get(requestsUrl, function (err, res, body) {
        if (!err) {
          responseTime = new Date().getTime() - start.getTime();
          
          if (res.statusCode == 200) {
            if (endpoints[city].format == 'xml') {
              try {
                var resRequests= parser.toJson(body, {object: true});    
                if (resRequests.service_requests.request) {
                  // if no service requests, '.services' doesn't exist
                  requestsCount15Min = resRequests.service_requests.request.length;
                }
              }
              catch(err) {
                console.log('Could not parse Requests XML for ' + city + '; ' + err);
                console.log(body);
              }
            } 
            else { 
              try {
                var resRequests = JSON.parse(body);
                requestsCount15Min = resRequests.length;
              }
              catch(err) {
                console.log('Could not parse Requests JSON for ' + city + '; ' + err);
                console.log(body);
              }
            }
          }
          else {
            console.log('Got a statusCode of ', res.statusCode, ' from ', requestsUrl);
          }

          var requestsPing = new RequestsPing({
             endpoint           : city
           , statusCode         : res.statusCode
           , responseTime       : responseTime
           , requestsCount15Min : requestsCount15Min
           , requestedAt        : start
          });
          
          requestsPing.save(function (err, requestsPing) {
            if (!err) {
              RequestsPings.push(requestsPing);
            }
            callback(); // our async callback
          });
        }  
      });
      
    }, function() {
      // Retrieved all Requests!
      pingCallback(RequestsPings);
    });  
  }
}


module.exports = Fetcher;


var isEmpty = function(obj) {
  var p;
  for (p in obj) {
    if (obj.hasOwnProperty(p)) {
        return false;
    }
  }
  return true;
};