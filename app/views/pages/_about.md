Open311 Status monitors and aggregates the status of dozens of Open311 API endpoints, providing benchmarks and comparative insights across cities and implementations for:

- **Upness**: the API is currently available
- **Uptime**: the availability of the API over time
- **Performance**: how quickly the servers respond to API requests
- **Comprehensiveness**: how fully the API is implemented/adopted; e.g. the number of service types that can be submitted through the API
- **Utilization**: how much the 311 service being used; e.g. the number of service requests submitted

Currently Open311status is unable to do the following despite it being very valuable:

- **Accuracy**: the API reflects the "ground-truth" status of a particular service request; e.g. if the API reports the status of a ticket as "closed", the pothole has been filled or the request explicitly rejected. We have observed some systems will report a ticket as "closed" when a separate internal work-order has been created but no externally visible action has actually been taken.

## Why is this important?

Comparative API performance data helps city leadership and 3rd-party application developers make better decisions about how they implement and support Open311:

It addresses common questions I saw from city leadership and application developers:

- **City Leadership**: How can we benchmark our configuration and adoption against other cities? How can we verify the standard of service we're delivering?
- **Application Developers**: What cities should we target for building our products?  Am I the only one experiencing problems with my integration?

Cities have various goals when adopting Open311 that can be affected by its implementation:

- Greater digital accessibility to 311 services, allowing residents to submit issues and check their status online or through mobile apps. _Adoption and usage of Open311 powered applications is affected by advertising, outreach and education._
- Improved efficiency in the delivery of 311 allowing self-serve access to tickets and reducing call-center usage _Open311-powered APIs may not make available all requests for self-service usage and may be configured to not accurately reflect the state of an ticket or issue._
- More effective delivery of city services by providing more precise resident feedback, including images and GPS data. _Implementation decisions can limit the features available within the API._
- Expand innovation by providing turn-key 3rd-party integration with city 311 services. _The performance and uptime of the API can affects whether application developers invest in integrations._

