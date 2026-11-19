#!/bin/bash

SD_LOGLEVEL=(-- -e SUPERVISORD_LOGLEVEL=INFO)

for arg in "$@"; do
	[[ "${arg}" == "--" ]] && SD_LOGLEVEL=(-e SUPERVISORD_LOGLEVEL=INFO) && break
done

rc=0
curl -fsSL https://raw.githubusercontent.com/lancachenet/test-suite/master/dgoss-tests.sh | bash -s -- --imagename="lancachenet/ubuntu:goss-test" "$@" "${SD_LOGLEVEL[@]}" || rc=1

"$(dirname "$0")/tests/exit-on-fatal.sh" "lancachenet/ubuntu:goss-test" || rc=1

exit ${rc}
