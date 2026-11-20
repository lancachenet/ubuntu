# Ubuntu Docker Image

This image provides a standard ubuntu docker base image for other docker images to build on top of.

It is currently based on 26.04 LTS

## Extending this image

This image uses [s6-overlay](https://github.com/just-containers/s6-overlay) as its init system and process supervisor. `/init` is the entrypoint, so any image built on top of this one should keep it.

Services are defined as [s6-rc](https://skarnet.org/software/s6-rc/) source definition directories:

* `/etc/s6-overlay/s6-rc.d/<name>/`
  The service definition. It needs a `type` file containing `oneshot` (runs once, for example setup tasks) or `longrun` (a supervised daemon), plus an `up` file for a oneshot or a `run` script for a longrun. An empty `dependencies.d/base` file makes it wait for the base services, and further files in `dependencies.d/` order it after other services.

* `/etc/s6-overlay/user-bundles.d/user/contents.d/<name>`
  An empty file that adds the service to the `user` bundle, which is started at container boot.

* `/etc/s6-overlay/s6-rc.d/<name>/finish`
  Optional. Runs when a longrun exits. To stop the container when the service dies, call `/run/s6/basedir/bin/halt`; the exit code written to `/run/s6-linux-init-container-results/exitcode` becomes the container's exit code.

s6 restarts a longrun every time it exits, so a service that can never start would leave the container running but broken. To stop the container with exit code 1 instead, use this as the service's `finish` script:

```sh
#!/bin/sh
exec /etc/s6-overlay/scripts/exit-on-fatal.sh "$@"
```

It treats the service as failed after it exits within 1 second of starting 4 times in a row, matching supervisord's `FATAL` state. A service that ran normally before exiting is just restarted, and `docker stop` is not treated as a failure. This is on by default (`EXIT_ON_FATAL=1`); set `EXIT_ON_FATAL=0` to keep restarting the service instead.

The ASCII logo in `overlay/etc/s6-overlay/s6-rc.d/asciilogo/` is a minimal oneshot example. `S6_BEHAVIOUR_IF_STAGE2_FAILS=2` is set, so the container stops if a oneshot fails during startup. See the [s6-overlay documentation](https://github.com/just-containers/s6-overlay#usage) for the full set of options.

## Usage

This docker image is not designed for use by anyone outside of the Lancache organisation, you're welcome to try, but support will be limited: HERE BE DRAGONS

1. Make a Dockerfile and specify `lancachenet/ubuntu` on the `FROM` line.
2. Anything you want run in the container should be defined as an s6-rc service (see above).
3. Use a directory called overlay if you need to copy files in to your new image (see Dockerfile for this image as an example).

## Building and testing

To build just run `docker build --tag lancachenet/ubuntu:testing .`.
To test you can run `./run-tests.sh`

## Changing container timezone

If you need to change the timezone that the container uses, it is defined by the `TZ` environment variable. The default is `Europe/London`.

```
 TZ=Europe/London
```

You can override this by using the `-e` argument to docker run and specifying your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

```
-e TZ="Australia/Melbourne"
```

