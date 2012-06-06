var express         = require('express')
  , app             = module.exports = express.createServer();
  
var PORT = process.env.PORT || 3000;

var HOURS_48   = 48 * 60 * 60 * 1000
  , MINUTES_15 =      15 * 60 * 1000
  , MINUTES_5  =       5 * 60 * 1000;

var EVERY5MINUTES = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

/** Set up the Database **/
var mongoose = require('mongoose')
  , Schema = mongoose.Schema
  , ObjectId = Schema.ObjectId;

if (process.env.MONGOHQ) {
  var MONGOHQ = process.env.MONGOHQ;
}
else {
  console.log("missing MONGOHQ environment variable");
}

mongoose.connect(MONGOHQ);
var RequestsPing = require('./models/requestsping.js');
var ServicesPing = require('./models/servicesping.js');

/** Load our Pinger functions to check the endpoints **/
var Pinger = require('./lib/pinger');
var Endpoints = require('./lib/endpoints');
var pinger = new Pinger(Endpoints);

/** Set up our Scheduler **/
var Scheduler = require('node-schedule');
// schedule every 15 minutes
var scheduledPings = Scheduler.scheduleJob({ minute: [0, 15, 30, 45] }, function(){
  pinger.pingServices(function(servicesPings) {
    console.log('Pinged ' + servicesPings.length + ' services endpoints.');
  });
  pinger.pingRequests(function(requestsPings) {
    console.log('Pinged ' + requestsPings.length + ' requests endpoints.');
  });
});

// Every hour delete pings older than 48 hours old
var cleanupPings = Scheduler.scheduleJob({ minute: [0] }, function(){
  ServicesPing.find()
              .where('requestedAt').lt(new Date(HOURS_48))
              .remove(function(servicePings){
    console.log('Removed ' + servicesPings.length + ' services endpoints older than 48 hours.');               
  });
  RequestsPing.find()
              .where('requestedAt').lt(new Date(HOURS_48))
              .remove(function(requestsPings){
    console.log('Removed ' + requestsPings.length + ' requests endpoints older than 48 hours.');               
  });
});


// Express Configuration
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.cookieParser());  
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

app.get('/', function(req, res) {
  var endpointCount = Object.keys(Endpoints).length;
  
  ServicesPing.find()
              .limit(endpointCount)
              .sort('requestedAt', -1)
              .run(function(err, servicesPings) {
                
      
    RequestsPing.find()
                .limit(endpointCount)
                .sort('requestedAt', -1)
                .run(function(err, requestsPings) {
       
       
      // TODO: Find a better way to convert Mongoose docs to objects
      servicesPings = servicesPings.map(function (servicesPing) {
         return servicesPing.toObject();
       });
       requestsPings = requestsPings.map(function (requestsPing) {
         return requestsPing.toObject();
       });
          
      res.render('index', { 
          title: 'Open311 Status'
        , endpoints: Endpoints
        , servicesPings: servicesPings
        , requestsPings: requestsPings
        });
    });                             
  });
});

app.listen(PORT, function(){
  
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});