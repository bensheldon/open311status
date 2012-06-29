Open311 Status
==============

Checks and displays the status of various Open311 endpoints. The list of endpoints currently being checked is in [`endpoints.json`](https://github.com/codeforamerica/open311status/blob/master/lib/endpoints.json)

These are the things this application tries to measure or provide insight into:

- **Upness**: are the servers currently running / accessible
- **Uptime**: Has the server been down recently?
- **Performance**: how quickly the servers respond; i.e. are they running slow?
- **Comprehensiveness**: does it seem like the service is fully implemented/userful; i.e. how many service request types are exposed?
- **Utilization**: is the endpoint actually being used; i.e. how many service requests were submitted) statistics?