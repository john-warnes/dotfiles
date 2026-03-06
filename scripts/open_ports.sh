#!/usr/bin/env bash
# open_ports.sh - List all open ports and associated services/programs

set -eu

echo "======================================================"
echo "    Open Ports and Associated Services/Programs"
echo "======================================================"
echo

if [[ "$EUID" -ne 0 ]]; then
    echo "WARNING: Not running as root. Process details may be incomplete." >&2
    echo "         Run with 'sudo' for complete results." >&2
    echo
fi

if ! command -v ss &>/dev/null; then
    echo "Error: 'ss' command not found. Please install iproute2." >&2
    exit 1
fi

echo "---- Listening Ports (ss) ----"
echo "[PROTO] PORT       LOCAL ADDRESS                PROGRAM"
echo "----------------------------------------------------------------------"
ss -tulnp | awk '
NR>1 {
    proto = $1
    local = $5
    pid = "-"
    prog = "-"

    # Extract "program_name",pid=1234
    if (match($0, /users:\(\(\"[^\"]+\",pid=[0-9]+/)) {
        str = substr($0, RSTART, RLENGTH)
        # Extract program
        p_start = index(str, "\"") + 1
        p_len = index(substr(str, p_start), "\"") - 1
        prog = substr(str, p_start, p_len)
        # Extract pid
        pid_start = index(str, "pid=") + 4
        pid = substr(str, pid_start)
    }

    printf "%-8s %-30s %-10s %-25s\n", toupper(proto), local, pid, prog
}
'

echo

if command -v lsof &>/dev/null; then
    echo "---- Detailed Process Info (lsof) ----"
    lsof -nP -iTCP -iUDP -sTCP:LISTEN 2>/dev/null | awk '
    NR == 1 {
        printf "%-20s %-10s %-15s %-30s %s\n", "COMMAND", "PID", "USER", "LOCAL ADDRESS", "TYPE"
        print "-------------------------------------------------------------------------------------"
        next
    }
    {
        cmd = $1
        pid = $2
        user = $3
        proto = $8
        addr = $9

        printf "%-20s %-10s %-15s %-30s %s\n", cmd, pid, user, addr, proto
    }
    '
    echo
fi

echo "======================================================"
echo " Summary (Port -> Program) [Unique]"
echo "======================================================"
echo "[PROTO] PORT       LOCAL ADDRESS                PROGRAM"
echo "----------------------------------------------------------------------"
ss -tulnp | awk '
NR>1 {
    proto = $1
    local = $5
    prog = "-"

    if (match($0, /users:\(\(\"[^\"]+\"/)) {
        str = substr($0, RSTART, RLENGTH)
        p_start = index(str, "\"") + 1
        p_len = index(substr(str, p_start), "\"") - 1
        if (p_len > 0) {
            prog = substr(str, p_start, p_len)
        }
    }

    port = local
    if (match(local, /:[0-9]+$/)) {
        split(local, a, ":")
        port = a[length(a)]
    }

    printf "[%-5s] %-10s %-25s -> %s\n", toupper(proto), port, local, prog
}
' | sort -u
