#!/bin/bash

[ "${DOCKER_DEBUG}" ] && set -x

die() {
	echo "ERROR: ${1}"
	exit 1
}

# PID, trap, wait; all belongs to 'docker stop' signal handeling.
# This is the same logic as the parent docker container, but rather this,
# than creating a one-time process in supervisord to handle this logic.
PID=
trap 'if [[ ${PID} ]]; then kill ${PID}; else exit 0; fi' SIGTERM SIGINT

supervisord_pre=$(find /hooks/supervisord-pre.d/ -maxdepth 1 -type f ! -name .gitkeep 2>/dev/null | sort -n)
if [ "$supervisord_pre" != "" ]; then
	for hook in $supervisord_pre; do
		echo "Executing hook ${hook}"
		if ! /bin/bash -c "${hook}"; then
			die "hook ${hook} returned a non-zero exit status '$?'"
		fi
	done
fi

[[ -f "/hooks/supervisord-pre" ]] && echo "The /hooks/supervisord-pre hook has been replaced with /hooks/supervisord-pre.d/*" && exit 1
#[ -f "/hooks/supervisord-pre" ] && /hooks/supervisord-pre

echo "Starting Supervisord"

rm -f /run/supervisord.fatal
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf -e "${SUPERVISORD_LOGLEVEL:-error}" &
PID=$!
wait ${PID}
rc=$?
# a trapped signal interrupts wait; keep waiting until supervisord has really exited
while kill -0 ${PID} 2>/dev/null; do
	wait ${PID}
	rc=$?
done
[[ -f /run/supervisord.fatal ]] && exit 1
exit ${rc}
