#!/command/with-contenv bash
# shellcheck shell=bash
# Stop the container when a longrun keeps failing to start, like supervisord's
# FATAL state (startsecs=1, startretries=3). Call it from the service's finish:
#
#   #!/bin/sh
#   exec /etc/s6-overlay/scripts/exit-on-fatal.sh "$@"
#
# Uptime is measured from when the service was last marked up or ready. On a
# restart that includes the 1s s6-supervise waits before respawning a service
# that died quickly, so that second is added to the threshold.
# Set EXIT_ON_FATAL=0 to disable.

STARTSECS=1
STARTRETRIES=3
RESTART_DELAY_MS=1000

[[ "${EXIT_ON_FATAL}" == 1 ]] || exit 0

read -r wantedup down up < <(s6-svstat -o wantedup,updownsince,readysince .)

# The service was told to stop (docker stop, s6-rc change), so this is not a failure.
[[ "${wantedup}" == true ]] || exit 0

name="${PWD##*/}"
state="/run/exit-on-fatal/${name}"
uptime_ms=$(((16#${down:1:16} - 16#${up:1:16}) * 1000 + (16#${down:17:8} - 16#${up:17:8}) / 1000000))

if ((uptime_ms >= STARTSECS * 1000 + RESTART_DELAY_MS)); then
	rm -f "${state}"
	exit 0
fi

count=$(($(cat "${state}" 2>/dev/null || echo 0) + 1))
if ((count > STARTRETRIES)); then
	echo "exit-on-fatal: ${name} exited within ${STARTSECS}s of starting ${count} times in a row, stopping the container"
	echo 1 >/run/s6-linux-init-container-results/exitcode
	exec /run/s6/basedir/bin/halt
fi

mkdir -p "${state%/*}"
echo "${count}" >"${state}"
