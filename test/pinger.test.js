var sinon = require('sinon')
  , request = require('request');

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
        .should.equal('https://open311.sfgov.org/V2/services.xml?jurisdiction=sfgov.org');
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
  
  
  describe('retrieve', function() {
    before(function(done) {
      this.city = {
        "endpoint": "https://open311.sfgov.org/V2/",
        "format": "xml",
        "jurisdiction": "sfgov.org"
      };
      done();
    });
    
    afterEach(function(done) {
      request.get.restore(); // restore our request method
      done();
    })
    
    it('should get response code', function(done) {
      sinon.stub(request, 'get', function(url, callback) {
          callback(null, 200, "foobar");
      });
      
      pinger.retrieve(this.city, 'services', function(results) {
        results.res.should.equal(200);
        done();
      })
    });
    
    it('should get response body', function(done) {
      sinon.stub(request, 'get', function(url, callback) {
          callback(null, 200, "foobar");
      });
      
      pinger.retrieve(this.city, 'services', function(results) {
        results.body.should.equal("foobar");
        done();
      })
    });
    
    it('should measure responseTime', function(done) {
      var TIMEOUT = 250;
      
     sinon.stub(request, 'get', function(url, callback) {
        setTimeout( function(){
          callback(null, 200, "foobar");
        }, TIMEOUT);
      });
      
      pinger.retrieve(this.city, 'services', function(results) {
        results.responseTime.should.be.within(TIMEOUT, TIMEOUT+10);
        done();
      })
    });
    
    it('should log errors', function(done) {
      //this.city.endpoint ="benttp://blark.crom";
      
      sinon.stub(request, 'get', function(url, callback) {
          callback('Error: Invalid protocol', null, null);
      });
      var spy = sinon.spy(console, "log");
      
      pinger.retrieve(this.city, 'services', function(results) {
        spy.args[0][0].should.equal('Failed to retrieve "https://open311.sfgov.org/V2/services.xml?jurisdiction=sfgov.org"; Error: Invalid protocol');
        done();
      })
    });
    
  });
});