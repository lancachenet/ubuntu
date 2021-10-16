#!/bin/bash

curl -fsSL https://raw.githubusercontent.com/lancachenet/test-suite/master/dgoss-tests.sh | bash -s -- --imagename="lancachenet/ubuntu:goss-test" $@
