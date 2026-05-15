#!/usr/bin/env bash
set -euo pipefail
python -c "from xr102232_test import add; assert add(1,1)==2"
echo "smoke ok"
