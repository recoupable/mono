#!/usr/bin/env bash
# Regenerate the canonical CSV spreadsheet from the pipe-delimited source.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import csv
rows=[l.rstrip('\n').split('|') for l in open('features.psv') if l.strip()]
ncol=len(rows[0])
with open('features.csv','w',newline='') as f:
    w=csv.writer(f)
    for r in rows:
        if len(r)<ncol: r=r+['']*(ncol-len(r))
        w.writerow(r[:ncol])
print(f"Wrote features.csv: {len(rows)-1} feature rows, {ncol} columns")
PY
