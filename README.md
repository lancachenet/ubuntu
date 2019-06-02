# Ubuntu Docker Image

This image provides a standard ubuntu docker base image for other docker images to build on top of.

It is currently based on 18.04 LTS (Bionic Beaver)

## Extending this image

You can easily extend the behavour of this image in the following ways

* `/hooks/entrypoint-pre.d/`
  Executables placed in this directory are executed very early on, before anything else is done.

* `/hooks/entrypoint-run`
  If it exists, this is executed if the default command is not overridden. After it's execution completes the default command is executed.

* `/hooks/entrypoint-exec`
  If it exists, this is executed if default command is overridden. After it's execution completes the default command is executed.

* `/hooks/supervisord-pre.d/`
  Executables placed in this directory are executed just before supervisord is executed.

* `/hooks/supervisord-ready`
  If it exists, this is executed once supervisord is read. This is triggered from supervisord itself, when it fires the SUPERVISOR_STATE_CHANGE_RUNNING event.

## Usage

This docker image is not designed for use by anyone outside of the steamcache organisation, you're welcome to try, but support will be limited: HERE BE DRAGONS

1. Make a Dockerfile and specify `lancachenet/ubuntu` on the `FROM` line.
2. Anything you want run in the container should be started by supervisord.
3. Use a directory called overlay if you need to copy files in to your new image (see Dockerfile for this image as an example).

## Building and testing

To build just run `docker build --tag lancachenet/ubuntu:testing .`.
To test you can run `./run_tests.sh`

## Changing container timezone

If you need to change the timezone that the container uses, it is defined by the `TZ` environment variable. The default is `Europe/London`.

```
 TZ=Europe/London
```

You can override this by using the `-e` argument to docker run and specifying your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

```
-e TZ="Australia/Melbourne"
```

