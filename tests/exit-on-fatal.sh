#!/bin/bash
# Usage: tests/exit-on-fatal.sh [image]
IMAGE="${1:-lancachenet/ubuntu:latest}"
CONF="$(mktemp -d)"
trap 'rm -rf "${CONF}"; docker rm -f eof-test >/dev/null 2>&1' EXIT

# service <name> <run script body>
service() {
	mkdir -p "${CONF}/$1/dependencies.d"
	touch "${CONF}/$1/dependencies.d/base" "${CONF}/$1.bundle"
	echo longrun >"${CONF}/$1/type"
	printf '#!/bin/bash\n%s\n' "$2" >"${CONF}/$1/run"
	printf '#!/bin/sh\nexec /etc/s6-overlay/scripts/exit-on-fatal "$@"\n' >"${CONF}/$1/finish"
	chmod +x "${CONF}/$1/run" "${CONF}/$1/finish"
}
service bad 'exec /nonexistent'
service graceful 'trap "echo GRACEFUL-STOP; exit 0" TERM; sleep 600 & wait'
chmod -R a+rX "${CONF}"

run() {
	docker rm -f eof-test >/dev/null 2>&1
	docker run -d --name eof-test -e "EXIT_ON_FATAL=$1" \
		-v "${CONF}/$2:/etc/s6-overlay/s6-rc.d/$2:ro" \
		-v "${CONF}/$2.bundle:/etc/s6-overlay/user-bundles.d/user/contents.d/$2:ro" \
		"${IMAGE}" >/dev/null
}

fail=0

run 1 bad
code=
for _ in $(seq 30); do
	[[ "$(docker inspect -f '{{.State.Running}}' eof-test)" == false ]] && code=$(docker inspect -f '{{.State.ExitCode}}' eof-test) && break
	sleep 1
done
if [[ "${code}" == 1 ]]; then
	echo "PASS: EXIT_ON_FATAL=1 exits 1"
else
	echo "FAIL: EXIT_ON_FATAL=1 expected exit 1, got '${code}'"
	fail=1
fi

run 0 bad
sleep 15
if [[ "$(docker inspect -f '{{.State.Running}}' eof-test)" == true ]]; then
	echo "PASS: EXIT_ON_FATAL=0 stays up"
else
	echo "FAIL: EXIT_ON_FATAL=0 container exited"
	fail=1
fi

run 1 graceful
sleep 5
if [[ "$(docker inspect -f '{{.State.Running}}' eof-test)" == true ]] && ! docker logs eof-test 2>&1 | grep -q exit-on-fatal; then
	echo "PASS: healthy start keeps running"
else
	echo "FAIL: healthy start was treated as fatal"
	fail=1
fi
start=${SECONDS}
docker stop eof-test >/dev/null
code=$(docker inspect -f '{{.State.ExitCode}}' eof-test)
if [[ "${code}" == 0 && $((SECONDS - start)) -lt 5 ]] && docker logs eof-test 2>&1 | grep -q GRACEFUL-STOP; then
	echo "PASS: docker stop is graceful (exit 0, children stopped)"
else
	echo "FAIL: docker stop not graceful (exit '${code}', $((SECONDS - start))s)"
	fail=1
fi

exit "${fail}"
