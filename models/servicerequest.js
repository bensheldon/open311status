var mongoose = require('mongoose'),
    Schema   = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var ServiceRequest = new mongoose.Schema({
      endpoint           : { type: String, required: true, lowercase: true, trim: true, index: true },
      service_request_id : { type: String, required: true },   
      requested_datetime : { type: Date, required: true, index: true},
      service_name       : { type: String },
      description        : { type: String },
      media_url          : { type: String },
      url                : { type: String }
});

// make sure endpoint+service_request_id is unique
ServiceRequest.index({ endpoint: 1, service_request_id: 1 }, { unique: true });

ServiceRequest.statics.timeSeries = function timeSeries (endpoint, startDate, endDate, callback) {
  var startDate = startDate || new Date( (new Date()).getTime() - 48*60*60*1000 );
  var endDate = endDate || new Date();
  var totalHours = Math.ceil( (endDate.getTime() - startDate.getTime())/(60*60*1000));

  var group = {
  	// create a new 'hour' key that corresponds to the 0th, 1st, 2nd, etc. hours
  	// from our startDate. This is what we'll group on.
  	keys: new Function( "doc", "\
  		docDate = new Date(doc.requested_datetime); \
  		return { hour: Math.floor((docDate.getTime() - "+startDate.getTime()+")/(60*60*1000)) } \
  	"),
    cond: {endpoint: endpoint, requested_datetime: {$gte: startDate, $lte: endDate} },
    reduce: function(doc, out) {
      out.count++;
    },
    initial: {
      count: 0
    },
    finalize: function(out) {
			//
    }
  };
  // call the group command
	this.collection.group(group.keys, group.cond, group.initial, group.reduce, group.finalize, true, function(err, results) {
	    var timeSeries = [];
	    // iterate through every hour and check if there is a corresponding result in our group
	    for(var i = 0; i < totalHours; i++) {
	    	timeSeries[i] = 0;
	    	for (var j = 0; j < results.length; j++) {
	    		if (results[j].hour == i) {
	    			timeSeries[i] = results[j].count;
	    			results.splice(j,1); // delete the element from the array just to slightly speed things along
	    		}
	    	}
	    }
	    // initiate the callback with our timeseries as the argument
	    callback(err, timeSeries);
	});
}

module.exports = mongoose.model('ServiceRequest', ServiceRequest);