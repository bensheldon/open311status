var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var ServicesSchema = new mongoose.Schema({
      endpoint        : { type: String, required: true, lowercase: true, trim: true, index: true },
      responseTime    : { type: Number, required: true },
      servicesCount   : { type: Number, required: true },
      requestedAt     : { type: Date, required: true },
      url			  : { type: String }

});

module.exports = mongoose.model('ServicesPing', ServicesSchema);