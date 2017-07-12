[![Build Status](https://travis-ci.org/mheese/journalbeat.svg?branch=master)](https://travis-ci.org/mheese/journalbeat)

# Journalbeat

Journalbeat is the [Beat](https://www.elastic.co/products/beats) used for log
shipping from systemd/journald based Linux systems. It follows the system journal
very much like `journalctl -f` and sends the data to Logstash/Elasticsearch (or
whatever you configured for your beat).

Journalbeat is targeting pure systemd distributions like CoreOS, Atomic Host, or
others. There are no intentions to add support for older systems that do not use
journald.

## Use Cases and Goals

Besides from the obvious use case (log shipping) the goal of this project is also
to provide a common source for more advanced topics like:
- FIM (File Integrity Monitoring)
- SIEM
- Audit Logs / Monitoring

This is all possible because of the tight integration of the Linux audit events
into journald. That said _journalbeat_ can only provide the data source for
these more advanced use cases. We need to develop additional pieces for
monitoring and alerting - as well as hopefully a standardized Kibana dashboard
to cover these features.

## Documentation

None so far. As of this writing, this is the first commit. There are things to
come. You can find a `journalbeat.yml` config file in the `etc` folder which
should be self-explanatory for the time being.

## Install

You need to install `systemd` development packages beforehand. In a
RHEL or Fedora environment, you need to install the `systemd-devel` package, `libsystemd-dev` in debian-based systems, et al.

`go get github.com/mheese/journalbeat`

**NOTE:** This is not the preferred way from Elastic on how to do it. Needs to
be revised (of course).

## Caveats

A few current caveats with journalbeat

### cgo

The underlying system library [go-systemd](https://github.com/coreos/go-systemd) makes heavy usage of cgo and the final binary will be linked against all client libraries that are needed in order to interact with sd-journal. That means that
the resulting binary is not really Linux distribution independent (which is kind of expected in a way).


# Journalbeat Docker

Journalbeat can be made to run in a Docker container. This documentation goes
over a few of the commands that can be used to manage the Docker containers.

## Build Container

From the main project directory, a docker container can be build like so:

    $ make docker-build

## Tag Container

A docker container can also be built for the current git tag. If the project is
ahead of a tag, the git describe will be used instead.  

    $ make docker-tag

## Cleanup

To remove any temporary files created from the build process, clean can be run:

    $ make clean

## How to use this image

### Start Journalbeat with commandline configuration

Once the docker container has been built, a quick way to get Journalbeat up and
running is to execute the command below:

    $ docker run -e LOGSTASH_HOST=logtashhost:5044 \
      -v /var/tmp/journalbeat:/data \
      -v /var/log/journal:/var/log/journal \
      -v /run/log/journal:/run/log/journal \
      -v /etc/machine-id:/etc/machine-id \
      --name journalbeat mheese/journalbeat

Note: Journalbeat requires access to resources only available on the host machine.
Because of this, Journalbeat only supports host machines running systemd. Make
sure to mount `/var/log/journal`, `/run/log/journal`, and `/etc/machine-id` for
Journalbeat to functional properly.

Although it's not required, mounting the `/data` volume to the host allows for
journal cursor data to be persistent for server reboots, docker image upgrades,
and docker image restarts.

When running with Docker, all application configuration should be set using
environment variables. The following environment variables are setup to be respected:

* LOGSTASH_HOST - The host and beat port for the logstash server. Example: 192.168.1.100:5044

### Start Journalbeat with configuration file

If you need to run Journalbeat with a configuration file, journalbeat.yml, that's
located in your current directory, you can use the Journalbeat image as follows:

    $ docker run -v "$PWD/journalbeat.yml":/journalbeat.yml \
    -v /var/log/journal:/var/log/journal \
    -v /run/log/journal:/run/log/journal \
    -v /etc/machine-id:/etc/machine-id \
    --name journalbeat mheese/journalbeat

### Using a Dockerfile

If you'd like to have a production Journalbeat image with a pre-baked configuration
file, use of a Dockerfile is recommended:

```
FROM mheese/journalbeat

COPY journalbeat.yml ./

CMD ["./journalbeat", "-e", "-c", "journalbeat.yml"]
```

Then, build with `docker build -t my-journalbeat` and deploy with something like
the following:

    $ docker run -d -v /var/log/journal:/var/log/journal \
    -v /run/log/journal:/run/log/journal \
    -v /etc/machine-id:/etc/machine-id \
    my-journalbeat
