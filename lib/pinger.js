var request     = require('request')
  , querystring = require('querystring')
  , parser      = require('xml2json')
  , async       = require('async');

require('datejs');

var RequestsPing = require('../models/requestsping.js')
  , ServicesPing = require('../models/servicesping.js')
  , ServiceRequest = require('../models/servicerequest.js');

var HOURS_48   = 48 * 60 * 60 * 1000;


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
                console.log('Could not parse Services XML for ' + city + ' (' + servicesUrl + '); ' + err);
                console.log(body);
              }
            }
            else {
              try {
                var resServices = JSON.parse(body);
                servicesCount = resServices.length;
              }
              catch(err) {
                console.log('Could not parse Services XML for ' + city + ' (' + servicesUrl + '); ' + err);
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
           , url           : servicesUrl
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
      
      // Search previous HOUR
      // TODO: make this more exact and not relative to the request
      var params = {
         start_date: new Date(d - 60 * 60 * 1000).toISOString()
       , end_date: d.toISOString()
      };
      var requestsUrl = self.formatEndpoint(endpoints[city], 'requests', params);
      
      var requestsCount = 0;
      var serviceRequests = [];
            
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
                  requestsCount = resRequests.service_requests.request.length;
                  serviceRequests = resRequests.service_requests.request;
                }
              }
              catch(err) {
                console.log('Could not parse Requests XML for ' + city + ' (' + requestsUrl + '); ' + err);
                console.log(body);
              }
            } 
            else { 
              try {
                var resRequests = JSON.parse(body);
                requestsCount = resRequests.length;
                serviceRequests = resRequests;

              }
              catch(err) {
                console.log('Could not parse Requests JSON for ' + city + ' (' + requestsUrl + '); ' + err);
                console.log(body);
              }
            }
          }
          else {
            console.log('Got a statusCode of ', res.statusCode, ' from ', requestsUrl);
          }

          // Save the requests to the database
          async.map(serviceRequests, function(serviceRequest, cb) {
            // make sure to check if it has a service_request_id
            // as some SRs haven't yet been assigned one
            if (serviceRequest.service_request_id) {
              (new ServiceRequest({
                endpoint           : city,
                service_request_id : serviceRequest.service_request_id,   
                requested_datetime : new Date(serviceRequest.requested_datetime),
                service_name       : serviceRequest.service_name,
                description        : serviceRequest.description,
                media_url          : serviceRequest.media_url,
              })).save(); // don't care if it succeeds, just try
            }
            cb();
          },
          function(err) {
            if (serviceRequests.length) {
              console.log("Added " + serviceRequests.length + " service requests from " + city + " to the database.")
            }
          });

          var requestsPing = new RequestsPing({
             endpoint           : city
           , statusCode         : res.statusCode
           , responseTime       : responseTime
           , requestsCount      : requestsCount
           , requestedAt        : start
           , url                : requestsUrl
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
  },
  pingAll: function(callback){
    var self = this;

    async.parallel([
      function(done){
        self.pingServices(function(servicesPings) {
          console.log('Pinged ' + servicesPings.length + ' services endpoints.');
          done();
        });
      },
      function(done){
        self.pingRequests(function(requestsPings) {
          console.log('Pinged ' + requestsPings.length + ' requests endpoints.');
          done();
        });
      },
    ],
    function(err){
      callback(err);
    });
  },
  cleanUp: function() {
    ServicesPing.find()
                .where('requestedAt').lt(new Date( (new Date).getTime() - HOURS_48 ))
                .remove(function(err, servicesPingsRemoved){
      console.log('Removed ' + servicesPingsRemoved + ' services pings older than 48 hours.');
    });
    RequestsPing.find()
                .where('requestedAt').lt(new Date( (new Date).getTime() - HOURS_48 ))
                .remove(function(err, requestsPingsRemoved){
      console.log('Removed ' + requestsPingsRemoved + ' requests pings older than 48 hours.');
    });
    ServiceRequest.find()
                .where('requested_datetime').lt(new Date( (new Date).getTime() - HOURS_48 ))
                .remove(function(err, requestsPingsRemoved){
      console.log('Removed ' + requestsPingsRemoved + ' service requests older than 48 hours.');
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