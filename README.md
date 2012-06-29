Open311 Status
==============

**http://open311status.herokuapp.com**

Checks and displays the status of various Open311 endpoints. The list of endpoints currently being checked is in [`endpoints.json`](https://github.com/codeforamerica/open311status/blob/master/lib/endpoints.json)

These are the things this application tries to measure or provide insight into:

- **Upness**: are the servers currently running / accessible
- **Uptime**: Has the server been down recently?
- **Performance**: how quickly the servers respond; i.e. are they running slow?
- **Comprehensiveness**: does it seem like the service is fully implemented/userful; i.e. how many service request types are exposed?
- **Utilization**: is the endpoint actually being used; i.e. how many service requests were submitted) statistics?

Installation
------------

1. Acquire a [MongoHQ](http://mongohq.com) database. Once acquired, it can be added to a `.env` file if using foreman locally (see `sample.env`). Or add it to your environment if pushing to heroku: `heroku add:config MONGOHQ=mongodb://<username>:<password>@url.mongohq.com:<port>/<database>`
2. Run it locally using `foreman run node server.js` (you can also just run `node server.js` as long as you have your MongoHQ database added as a local `MONGOHQ` environment variable) or push it to Heroku.
3. The scripts that pull down data into the database run every 5 minutes, so you may have to wait a bit for data to start appearing.
4. You can add/remove endpoints in the `/lib/endpoints.json` file.
