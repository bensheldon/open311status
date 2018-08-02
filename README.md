Open311 Status
==============

**http://status.open311.org**

Open311 Status monitors and aggregates the status of dozens of Open311 API endpoints, providing benchmarks and comparative insights into:

- **Upness**: the API is currently available
- **Uptime**: the availability of the API over time
- **Performance**: how quickly the servers respond to API requests
- **Comprehensiveness**: how fully the API is implemented/adopted; e.g. the number of service types that can be submitted through the API
- **Utilization**: how much the 311 service being used; e.g. the number of service requests submitted

## Development setup

### Requirements
1. Install Ruby with your ruby version manager of choice, like [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://github.com/codeforamerica/howto/blob/master/Ruby.md)
2. Check the ruby version in `.ruby-version` and ensure you have it installed locally e.g. `rbenv install 2.5.1`
3. Install [bundler](https://bundler.io/) (the latest Heroku-compatible version): `gem install bundler`
4. [Install Postgres](https://github.com/codeforamerica/howto/blob/master/PostgreSQL.md). If setting up Postgres.app, you will also need to add the binary to your path. e.g. Add to your `~/.bashrc`:
`export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"`

### Application Setup

1. Install ruby gem dependencies: `bundle install`
2. Create the databases and load schema and seeds: `bin/rails db:setup`
3. Run the tests: `bin/rspec`
4. Run the server: `bin/rails server`, and visit the web-browser: [`http://localhost:3000`](http://localhost:3000)
