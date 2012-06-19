var express         = require('express')
  , app             = module.exports = express.createServer()
  , io              = require('socket.io').listen(app);
  
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
var ServiceRequest = require('./models/servicerequest.js');


/** Load our Pinger functions to check the endpoints **/
var Pinger = require('./lib/pinger');
var Endpoints = require('./lib/endpoints');
var pinger = new Pinger(Endpoints);

/** Set up our Cron **/
var CronJob = require('cron').CronJob;

// schedule every 5 minutes
var scheduledPings = new CronJob('00 */5 * * * *', function() { pinger.pingAll() }, null, true);
// Every hour delete pings older than 48 hours old
var cleanupPings = new CronJob('00 00 * * * *', function() { pinger.cleanUp() }, null, true);

var replayRequests = new CronJob('00 */5 * * * *', function() {
  var d = new Date();
  // get all service requests from between 1 hour and 55 minute ago
  var serviceRequests = ServiceRequest.find()
                                      .where('requested_datetime').gte(new Date(d.getTime() - 60*60*1000)).lte(new Date(d.getTime() - 55*60*1000))
                                      .sort('requested_datetime', 1)
                                      .stream();
  serviceRequests.on('data', function (serviceRequest) {
    serviceRequest = serviceRequest.toObject();

    var when = new Date(serviceRequest.requested_datetime.getTime() + 60*60*1000); // add 1 hour
    Scheduler.scheduleJob(when, function(){
      io.sockets.emit('serviceRequest', serviceRequest); // emit to socket
    });
  })
}, null, true);


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
  io.set('log level', 1); // reduce logging
});

app.get('/', require('./routes/index'));
app.get('/services/:endpoint', require('./routes/services'));



// assuming io is the Socket.IO server object
io.configure(function () { 
  io.set("transports", ["xhr-polling"]); 
  io.set("polling duration", 10); 
});

io.sockets.on('connection', function (socket) {
  socket.emit('info', { hello: 'world' });
});

app.listen(PORT, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});