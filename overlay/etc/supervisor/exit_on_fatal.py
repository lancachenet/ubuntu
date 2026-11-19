#!/usr/bin/env python3
import os
import signal
import sys

FLAG = "/run/supervisord.fatal"


def main():
    while True:
        sys.stdout.write("READY\n")
        sys.stdout.flush()
        line = sys.stdin.readline()
        if not line:
            return
        headers = dict(kv.split(":", 1) for kv in line.split())
        sys.stdin.read(int(headers["len"]))
        if os.environ.get("SUPERVISORD_EXIT_ON_FATAL") == "1":
            # supervisord exits 0 on SIGTERM; supervisord.sh turns the flag into exit 1
            open(FLAG, "w").close()
            os.kill(os.getppid(), signal.SIGTERM)
        sys.stdout.write("RESULT 2\nOK")
        sys.stdout.flush()


main()
