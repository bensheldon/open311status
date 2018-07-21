
describe('endpoints', function(){
  var endpoints = require('../lib/endpoints');

  it('is a valid json doc',  function(done) {
    endpoints.should.be.a('object');
    done();
  });

  describe('san francisco', function() {
    endpoints.should.have.property('san francisco');
    it('has an endpoint URL',  function(done) {
      endpoints["san francisco"].should.have.property('endpoint', 'https://open311.sfgov.org/V2/');
      done();
    });
    it('has format of xml',  function(done) {
      endpoints["san francisco"].should.have.property('format', 'xml');
      done();
    });
    it('has a jurisdiction',  function(done) {
      endpoints["san francisco"].should.have.property('jurisdiction', 'sfgov.org');
      done();
    });
  });

  describe('all endpoints', function() {

    it('have an endpoint URL',  function(done) {
      for(var city in endpoints) {
        city = endpoints[city];
        city.should.have.property('endpoint');
      }
      done();
    });

  });


})
