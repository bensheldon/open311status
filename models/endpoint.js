var mongoose = require('mongoose'),
    Schema   = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var RequestsPing = require('../models/requestsping.js')
  , ServicesPing = require('../models/servicesping.js')
  , ServiceRequest = require('../models/servicerequest.js')
  , EndpointModel = require('../models/endpoint.js');

var async       = require('async');
var Endpoints = require('../lib/endpoints');

var Endpoint = new mongoose.Schema({
      endpoint           : { type: String, required: true, lowercase: true, trim: true, index: true, unique: true },
      info               : {},
      servicesPing       : {},
      requestsPing       : {},
      requests           : {} //min, max, sum, avg, timeSeries
});

Endpoint.statics.generateAll = function generateAll (callback) {
  var self = this;
  var endpoints = [];

  async.forEachSeries(Object.keys(Endpoints), function(city, done) {
    self.generate(city, function(err, endpoint) {
      endpoints.push(endpoint)
      done();
    });
  },
  function (err) {
    callback(err, endpoints);
  });
};

Endpoint.statics.generate = function generate (city, callback) {
  var self = this;

  this.findOne()
      .where('endpoint', city)
      .run(function(err, endpoint) {
    if (!endpoint) {
      // TODO: there has to be a better/less-self-referential way to do this
      endpoint =  new (mongoose.model('EndPoint', Endpoint)); 
      endpoint.endpoint = city;
    }
    endpoint.set('info', Endpoints[city]);

    async.series([
      function(done){
        // load latest ServicesPing
        ServicesPing.findOne()
              .where('endpoint', city)
              .limit(1)
              .sort('requestedAt', -1)
              .run(function(err, servicesPing) {
          if (servicesPing) {
            endpoint.servicesPing = servicesPing.toObject();
          }
          else {
            endpoint.servicesPing = null;
          }
          done();
        });
      },
      function(done){
        // load latest RequestsPing 
        RequestsPing.findOne()
                    .where('endpoint', city)
                    .limit(1)
                    .sort('requestedAt', -1)
                    .run(function(err, requestsPing) {
          if (requestsPing) {
            endpoint.requestsPing = requestsPing.toObject();
          }
          else {
            endpoint.requestsPing = null;
          }
          done();
        });
      },
      function(done){
        // do our requestsTimeSeries
        ServiceRequest.statistics(city, false, false, function(err, statistics){
          endpoint.requests = statistics;
          done();
        });
      }
    ],
    // optional callback
    function(err, results){
      endpoint.save(callback);
    }); // /async.series
  });
};


module.exports = mongoose.model('EndPoint', Endpoint);