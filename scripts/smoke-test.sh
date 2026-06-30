```bash
#!/usr/bin/env bash
set -euo pipefail

ALB_URL="${1:?Usage: smoke-test.sh <ALB_URL>}"

MAX_RETRIES=5
RETRY_DELAY=15
RESPONSE_THRESHOLD=2.0

echo "=================================================="
echo "Running Smoke Tests"
echo "Target: ${ALB_URL}"
echo "=================================================="

###############################################################################
# Health Check
###############################################################################

echo ""
echo "▶ Checking /health..."

for i in $(seq 1 "$MAX_RETRIES"); do

    HTTP_CODE=$(curl \
        --silent \
        --output health.json \
        --write-out "%{http_code}" \
        "${ALB_URL}/health" || echo "000")

    STATUS=$(python3 <<EOF
import json
try:
    with open("health.json") as f:
        print(json.load(f).get("status","unknown"))
except Exception:
    print("invalid")
EOF
)

    if [[ "$HTTP_CODE" == "200" && "$STATUS" == "healthy" ]]; then
        echo "✅ Health endpoint passed"
        break
    fi

    if [[ "$i" == "$MAX_RETRIES" ]]; then
        echo "❌ Health check failed"
        echo "HTTP Status : $HTTP_CODE"
        echo "Response:"
        cat health.json || true
        exit 1
    fi

    echo "Attempt ${i}/${MAX_RETRIES} failed..."
    sleep "$RETRY_DELAY"

done

###############################################################################
# API Check
###############################################################################

echo ""
echo "▶ Checking /api/history..."

HTTP_CODE=$(curl \
    --silent \
    --output history.json \
    --write-out "%{http_code}" \
    "${ALB_URL}/api/history")

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "❌ API returned HTTP ${HTTP_CODE}"
    exit 1
fi

python3 <<EOF
import json
import sys

try:
    with open("history.json") as f:
        json.load(f)
except Exception:
    print("History endpoint did not return valid JSON.")
    sys.exit(1)
EOF

echo "✅ API endpoint passed"

###############################################################################
# Response Time
###############################################################################

echo ""
echo "▶ Measuring response time..."

RESPONSE_TIME=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{time_total}" \
    "${ALB_URL}/health")

python3 <<EOF
import sys

response=float("${RESPONSE_TIME}")
threshold=float("${RESPONSE_THRESHOLD}")

if response < threshold:
    print(f"✅ Response time: {response:.3f}s")
else:
    print(f"⚠️ Slow response time: {response:.3f}s (threshold {threshold}s)")
EOF

###############################################################################
# Cleanup
###############################################################################

rm -f health.json history.json

echo ""
echo "=================================================="
echo "✅ All smoke tests passed!"
echo "=================================================="
```

