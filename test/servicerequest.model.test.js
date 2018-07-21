var sinon = require('sinon')
  , request = require('request');

var fs = require('fs');

var mongoose = require('mongoose');
mongoose.connect(process.env.MONGOHQ);

describe('ServiceRequest Model', function(){
  var ServiceRequest = require('../models/servicerequest.js');

  describe('.timeSeries()', function() {
    it("generates a default Time Series of 48 hours", function(done) {
      ServiceRequest.timeSeries('dc', false, false, function(err, timeSeries){
        timeSeries.length.should.equal(48);
        done();
      });
    });
  });
});
