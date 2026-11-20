#!/bin/bash

rc=0
curl -fsSL https://raw.githubusercontent.com/lancachenet/test-suite/master/dgoss-tests.sh | bash -s -- --imagename="lancachenet/ubuntu:goss-test" "$@" || rc=1

"$(dirname "$0")/tests/exit-on-fatal.sh" "lancachenet/ubuntu:goss-test" || rc=1

exit ${rc}
