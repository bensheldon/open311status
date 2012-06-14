var mongoose = require('mongoose'),
    Schema   = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var ServiceRequest = new mongoose.Schema({
      endpoint           : { type: String, required: true, lowercase: true, trim: true, index: true },
      service_request_id : { type: String, required: true },   
      requested_datetime : { type: Date, required: true },
      service_name       : { type: String },
      description        : { type: String },
      media_url          : { type: String },
      url                : { type: String }
});

// make sure endpoint+service_request_id is unique
ServiceRequest.index({ endpoint: 1, service_request_id: 1 }, { unique: true });

module.exports = mongoose.model('ServiceRequest', ServiceRequest);