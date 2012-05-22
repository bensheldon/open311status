var request = require('request')
  , querystring = require('querystring');

var Fetcher = function(mongoose, endpoints) {
  this.mongoose = mongoose;
  this.endpoints = endpoints;
};

Fetcher.prototype = {
  
  formatEndpoint: function(endpoint, method) {
    var url    = ''
      , params = {}
      , format = endpoint.format || 'json';
    
    if(endpoint.jurisdiction) {
      params.jurisdiction = endpoint.jurisdiction;
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
  
  retrieve: function(city, method, callback) {
    var start = new Date(); // Set a timer
    var url = this.formatEndpoint(city, method);
    request.get(url, function (err, res, body) {
      var responseTime = new Date().getTime() - start.getTime();
      
      if(!err) {      
        callback({
          responseTime: responseTime,
          err: err,
          res: res,
          body: body
        });
      }
      else {
        console.log('Failed to retrieve "' + url + '"; ' + err);
        callback({
          err: err,
          res: null,
          body: null
        })
      }
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