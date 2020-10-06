# Ubuntu Docker Image

This image provides a standard ubuntu docker base image for other docker images to build on top of.

It is currently based on 18.04 LTS (Bionic Beaver)

## Extending this image

You can easily extend the behavour of this image in the following ways

* `/etc/fix-attrs.d`
  Fix ownership and permissions before anything else is executes. These files require a specific format detailed [here](https://github.com/just-containers/s6-overlay#fixing-ownership--permissions).

* `/etc/cont-init.d`
  Executables in this folder are run prior to any services being started.

* `/etc/services.d`
  Services are defined in this directory. A service is defined by creating a directory with the service name with a run file in it.

* `/etc/cont-finish.d`
  Executables placed in this directory are executed after a service has died.

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

