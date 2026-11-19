#!/bin/bash
# Usage: tests/exit-on-fatal.sh [image]
IMAGE="${1:-lancachenet/ubuntu:latest}"
CONF="$(mktemp -d)"
trap 'rm -rf "${CONF}"; docker rm -f eof-test >/dev/null 2>&1' EXIT
cat >"${CONF}/bad.conf" <<'CFG'
[program:bad]
command=/nonexistent
startretries=1
CFG
cat >"${CONF}/graceful.conf" <<'CFG'
[program:graceful]
command=/bin/bash -c 'trap "echo GRACEFUL-STOP; exit 0" TERM; sleep 600 & wait'
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
CFG
chmod -R a+rX "${CONF}"

run() {
	docker rm -f eof-test >/dev/null 2>&1
	docker run -d --name eof-test -e "SUPERVISORD_EXIT_ON_FATAL=$1" -e SUPERVISORD_LOGLEVEL=INFO \
		-v "${CONF}/$2.conf:/etc/supervisor/conf.d/$2.conf:ro" "${IMAGE}" >/dev/null
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
if docker logs eof-test 2>&1 | grep -q spawnerr; then
	echo "FAIL: healthy start logged spawnerr"
	fail=1
else
	echo "PASS: healthy start has no spawnerr"
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
