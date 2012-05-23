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