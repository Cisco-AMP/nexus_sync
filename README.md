# Nexus Sync

Copy items between Nexus server instances using the [Nexus API](https://github.com/Cisco-AMP/nexus_api) gem.


## Usage
To use the script you'll need to create a `.env` file. Use `.env.template` in the top level directory to do this.

You can view the command line options with the `-h` flag:
```
bin/nexus_sync -h
```

### CAVEATS
1) Nexus Sync caches both files and docker images on the host running the sync and DOES NOT clean up after itself. If running this script on a consistent basis it's important to create a cron job (or something equivalent) to clean BOTH the cached files (in `./downloads` by default) AND local docker images (`docker images -a`).

2) Nexus Sync can only interact with docker repos that have been configured with an HTTP Connector (found in Nexus' Repository settings for a docker repo) fronted by an nginx rule (or other equivalent service). The source and destination repos are configured via `DOCKER_PULL_URL` and `DOCKER_PUSH_URL` in `.env`. If pulling from a `group` repo, the user can filter on any repo name that is a part of that group.


## Running the tests
To run the tests you'll need to create a `.env.test` file. Use `.env.test.template` in the top level directory to do so.

```
bundle exec rspec
```