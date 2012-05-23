var sinon = require('sinon')
  , request = require('request');
  
var fs = require('fs');

var mongoose = require('mongoose');

/** USE OUR TEST DATABASE **/
process.env.MONGOHQ = process.env.MONGOHQ_TEST;

describe('fetcher', function(){
  var Pinger = require('../lib/pinger');
  var pinger = new Pinger();
  
  describe('formatEndpoint', function() {  
    it('should format San Francisco (endpoint, format, jurisdiction)', function(done) {  
      var endpoint = {
        "endpoint": "https://open311.sfgov.org/V2/",
        "format": "xml",
        "jurisdiction": "sfgov.org"
      };
      pinger.formatEndpoint(endpoint, "services")
        .should.equal('https://open311.sfgov.org/V2/services.xml?jurisdiction_id=sfgov.org');
      done();
    });
    
    it('should format Bainbridge (just endpoint)', function(done) {
      var endpoint = {
        "endpoint": "http://seeclickfix.com/bainbridge-island/open311/"
      };
      pinger.formatEndpoint(endpoint, "services")
        .should.equal('http://seeclickfix.com/bainbridge-island/open311/services.json');
      done();
    });
  });
  
  describe('ping function', function() {
    
    beforeEach(function(done) { 
      // Stub Model.save()
      sinon.stub(mongoose.Model.prototype, 'save', function(callback) {
        callback(this);
      });
      done();
    })
    
    afterEach(function(done) {
      // clean up our stubs
      mongoose.Model.prototype.save.restore();
      done();
    })
    
    var endpoints = {
      'san francisco': {
        "endpoint": "https://open311.sfgov.org/V2/",
        "format": "xml",
        "jurisdiction": "sfgov.org"
      },
      "toronto": {
          "endpoint": "https://secure.toronto.ca/webwizard/ws/",
          "jurisdiction": "toronto.ca"
      }
    };
    
    var Pinger = require('../lib/pinger');
    var pinger = new Pinger(mongoose, endpoints);
    
    describe('pingServices', function() {
      beforeEach(function(done) {
        // Stub Request.get()
        sinon.stub(request, 'get', function(url, callback) {
          if (url.search(/^https\:\/\/open311.sfgov.org\/V2\/.*/) !== -1) {
            callback(null, { statusCode: 200 }, fs.readFileSync('./test/mocks/san_francisco_services.xml') );
          }
          else {
            callback(null, { statusCode: 200 }, '{}' );
          }
        });
        done();
      });
      afterEach(function(done) {
        request.get.restore();
        done();
      });
      
      it('should request Services from each endpoint in list of endpoints', function(done) {
        pinger.pingServices(function(servicesPings) {
          request.get.args.length.should.equal(2) // Should make 1 request for each endpoint
          done();
        });      
      });
      it('should save to Mongo', function(done) {
        pinger.pingServices(function(requestsPings) {
          mongoose.Model.prototype.save.args.length.should.equal(2) // Should make 1 save for each endpoint
          done();
        });      
      });
      it('should save san francisco endpoint to Mongo', function(done) {
        pinger.pingServices(function(requestsPings) {
          mongoose.Model.prototype.save.thisValues[0].endpoint.should.equal('san francisco')
          done();
        });      
      });
    });

    describe('pingRequests', function() {
      beforeEach(function(done) {
        // Stub Request.get()
        sinon.stub(request, 'get', function(url, callback) {
          if (url.search(/^https\:\/\/open311.sfgov.org\/V2\/.*/) !== -1) {
            callback(null, { statusCode: 200 }, fs.readFileSync('./test/mocks/san_francisco_requests.xml') );
          }
          else {
            callback(null, { statusCode: 200 }, '{}' );
          }
        });
        done();
      });
      afterEach(function(done) {
        request.get.restore();
        done();
      });
      
      it('should request Requests from each endpoint in list of endpoints', function(done) {
        pinger.pingRequests(function(requestsPings) {
          request.get.args.length.should.equal(2) // Should make 1 request for each endpoint
          done();
        });      
      });
      it('should save Requests data to Mongo', function(done) {
        pinger.pingRequests(function(requestsPings) {
          mongoose.Model.prototype.save.args.length.should.equal(2) // Should make 1 save for each endpoint
          done();
        });      
      });
      it('should save san francisco endpoint to Mongo', function(done) {
        pinger.pingRequests(function(requestsPings) {
          mongoose.Model.prototype.save.thisValues[0].endpoint.should.equal('san francisco')
          done();
        });      
      });
    });
  });
});