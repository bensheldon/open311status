var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;
    
var RequestsPing = new mongoose.Schema({
      endpoint           : { type: String, required: true, lowercase: true, trim: true, index: true },
      requestsCount      : { type: Number, required: true },
      responseTime       : { type: Number, required: true },
      requestedAt        : { type: Date, required: true },
      url                : { type: String }
});

module.exports = mongoose.model('RequestsPing', RequestsPing);