var express         = require('express')
  , app             = module.exports = express.createServer();
  
var PORT = process.env.PORT || 3000;

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
// schedule every 5 minutes
var scheduledPings = Scheduler.scheduleJob({ minute: EVERY5MINUTES }, function() { pinger.pingAll() });
// Every hour delete pings older than 48 hours old
var cleanupPings = Scheduler.scheduleJob({ minute: 0 }, function() { pinger.cleanUp() });

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

app.get('/', require('./routes/index'));
app.get('/services/:endpoint', require('./routes/services'));


app.listen(PORT, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});