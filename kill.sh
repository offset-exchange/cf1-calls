#!/bin/bash
# LendSignal kill switch. Edits status.json, commits, pushes.
# The live pages poll status.json every 15 seconds with cache disabled, so a change
# takes effect within ~15s even for people who are already logged in.
#
#   ./kill.sh mine    -> only Ants can use it; everyone else sees the retired message
#   ./kill.sh all     -> nobody can use it, Ants included
#   ./kill.sh on      -> back to normal for everyone
#   ./kill.sh status  -> show the current state
set -e
cd /home/claude/cf1-calls
F=status.json

case "$1" in
  mine)
    cat > $F <<'JSON'
{"active":false,"hard":false,"only":["Anthony Vigil"],"message":"This tool is offline. Ask Anthony Vigil for the current link."}
JSON
    MSG="Kill switch: owner only"
    ;;
  all)
    cat > $F <<'JSON'
{"active":false,"hard":true,"only":[],"message":"This tool has been retired."}
JSON
    MSG="Kill switch: full stop"
    ;;
  on)
    cat > $F <<'JSON'
{"active":true,"hard":false,"message":""}
JSON
    MSG="Kill switch: back on for everyone"
    ;;
  status)
    echo "local:  $(cat $F)"
    echo "live:   $(curl -s "https://offset-exchange.github.io/cf1-calls/status.json?t=$(date +%s)" || echo unreachable)"
    exit 0
    ;;
  *)
    echo "usage: ./kill.sh [mine|all|on|status]"; exit 1
    ;;
esac

echo "$MSG"
cat $F
git add $F
git commit -q -m "$MSG" || { echo "nothing to commit"; exit 0; }
git push -q origin main
echo "pushed. live within ~15s of the Pages deploy finishing (usually under 2 min)."
