Open311 Status
==============

**Website**: http://status.open311.org

**Project Backlog**: https://github.com/codeforamerica/open311status/projects/1

Open311 Status monitors and aggregates the status of dozens of Open311 API endpoints, providing benchmarks and comparative insights into:

- **Upness**: the API is currently available
- **Uptime**: the availability of the API over time
- **Performance**: how quickly the servers respond to API requests
- **Comprehensiveness**: how fully the API is implemented/adopted; e.g. the number of service types that can be submitted through the API
- **Utilization**: how much the 311 service being used; e.g. the number of service requests submitted

![Demo Image](https://raw.githubusercontent.com/codeforamerica/open311status/master/SCREENSHOT.png)

## Development

### Adding new API endpoints

To add a new Open311 endpoint, add their API configuration to the [`config/cities.yml`](config/cities.yml) file. This should include:
- `slug`: a unique key for the API endpoint.
    - `name`: the human readable name of the city or location.
    - `endpoint`: the complete URL of the Open311 api endpoint, ending in a `/`, _without_ `services.xml` or `requests.xml`.
    - `jurisdiction` (optional): the `?jurisdiction_id=` parameter, if required.
    - `format` (optional): `xml` or `json`; defaults to `xml`/
    - `headers` (optional): custom API headers necessary for the API.

Example:

```yml
bruhl:
  name: 'Brühl, Deutschland'
  endpoint: 'https://www.achtet-auf-bruehl.de/georeport/v2/'
  jurisdiction: 'bruehl.de'
```

### How it works

Open311 Status is a static website built with [Parklife](https://github.com/benpickles/parklife) from a Rails app that has no database:

- **Data** lives as YAML in the `data` branch (`cities/<slug>.yml`: service definitions, status checks, and recent service requests), keeping it out of `main`. The app reads it from `./data` (override with `DATA_PATH`).
- **Fetching**: the [Fetch and Publish workflow](.github/workflows/fetch_and_publish.yml) runs hourly, checks out the `data` branch into `./data`, runs `bin/rails data:fetch`, commits and pushes the `data` branch, then builds the site with `bin/parklife build` and publishes `./build` to the `gh-pages` branch. Pushes to `main` rebuild and publish without fetching.
- **Retention**: status checks are kept for 6 months and service requests for 7 days (`City::STATUS_RETENTION`, `City::SERVICE_REQUEST_RETENTION`); older history remains in the `data` branch's git history.

### Loading data locally

- `bin/data` checks out the `data` branch into `./data` as a git worktree (or pulls it if already present).
- `bin/rails data:fetch` fetches fresh data from every endpoint into `./data`. Limit with `SLUGS=chicago,boston`.
- `bin/rails data:backfill` deep-backfills service requests across the whole retention window (walking date ranges to get past endpoint page limits). In CI, run "Fetch and Publish" manually with the "backfill" option.

### JavaScript

JavaScript is managed via [importmap-rails](https://github.com/rails/importmap-rails) — no Node.js or build step required. Vendor packages (Chart.js, Bootstrap, Stimulus) are downloaded to `vendor/javascript/` and served directly by Rails.

To add or update a package:
```sh
bin/importmap pin <package>
```

To remove a package:
```sh
bin/importmap unpin <package>
```

### Application Setup

No database is required.

1. Install dependencies and check out data: `bin/setup`
2. Run the tests: `bin/rspec`
3. Run the server: `bin/rails server`, and visit [`http://localhost:3000`](http://localhost:3000)
4. Build the static site: `bin/parklife build` (output in `./build`)
