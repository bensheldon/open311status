var express         = require('express')
  , app             = module.exports = express.createServer();
  
var PORT = process.env.PORT || 3000;

/** Set up the Database **/
var mongoose = require('mongoose')
  , Schema = mongoose.Schema
  , ObjectId = Schema.ObjectId;

if (process.env.MONGOHQ) {
  var MONGOHQ = process.env.MONGOHQ;
}
else {
  console.log("missing MONGOHQ environment variable");
  exit();
}
mongoose.connect(MONGOHQ);
var Schemas        = require("../lib/schemas")
  , ServicesPing   = mongoose.model('ServicesPings', Schemas.ServicesSchema)
  , RequestsPing   = mongoose.model('RequestsPing', Schemas.RequestsPing);

/** Load our Pinger functions to check the endpoints **/
var Pinger = require('./lib/pinger');
var Endpoints = require('./lib/endpoints');
var pinger = new Pinger(mongoose, Endpoints);

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
  res.render('index', { 
      title: 'Open311 Status' 
    });
});

app.listen(PORT, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});