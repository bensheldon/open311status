var sinon = require('sinon')
  , request = require('request');

var fs = require('fs');

var mongoose = require('mongoose');
mongoose.connect(process.env.MONGOHQ);

describe('Endpoint Model', function(){
  var Endpoint = require('../models/endpoint.js');

  describe('.generate()', function() {
    it("inserts a new object with our data", function(done) {
      Endpoint.generate('dc', function(err, endpoint){
        done();
      });
    });
  });
  describe('.generateAll()', function() {
    it("inserts ALL objects with our data", function(done) {
      Endpoint.generateAll(function(err, endpoints) {
        done();
      });
    });
  });
});
