#!/bin/bash
set -e
source "utils/parse-k6-summary.sh"

CONFIG="config/config.json"
DATETIME=$(TZ=Asia/Bangkok date +"%d%m%Y-%H%M")

VUS=($(jq -r '.VUS[]' $CONFIG))
DURATION=$(jq -r '.DURATION' $CONFIG)
WAIT_BETWEEN_STEPS_SEC=$(jq -r '.WAIT_BETWEEN_STEPS_SEC' $CONFIG)
HTML_REPORT=$(jq -r '.HTML_REPORT' $CONFIG)

if [ -n "$API" ]; then
    APIS=($API)
else
    APIS=($(jq -r '.APIS[]' $CONFIG))
fi

for name in "${APIS[@]}"; do
    OUTPUT_DIR="reports/${name}_${DATETIME}"
    SUMMARY_TSV="${OUTPUT_DIR}/summary_${DATETIME}.tsv"
    mkdir -p "$OUTPUT_DIR"

    if [ ! -f "$SUMMARY_TSV" ]; then
    echo -e "API\tVU\tIterations\tRequests\tError%\tAvg(ms)\tP90\tMax\tDataSent\tDataRecv" > "$SUMMARY_TSV"
    fi

    for ((i=0; i<${#VUS[@]}; i++)); do
        vu="${VUS[$i]}"
        JSON_SUMMARY="${OUTPUT_DIR}/summary-${name}_${DATETIME}-${vu}.json"
        REPORT_HTML="report-${name}_${DATETIME}-${vu}.html"

        echo "🚀 Running $name @ VU=$vu"

        k6 run \
        --vus "$vu" \
        --duration "$DURATION" \
        --env API_NAME="$name" \
        --env VU="$vu" \
        --env HTML_REPORT="$HTML_REPORT" \
        --env REPORT_PATH="${OUTPUT_DIR}/${REPORT_HTML}" \
        --summary-export="$JSON_SUMMARY" \
        stress-test.js

        parse_summary_json "$JSON_SUMMARY" "$name" "$vu" >> "$SUMMARY_TSV"
        cat $SUMMARY_TSV
        if (( i < ${#VUS[@]} - 1 )); then
            echo "⏸️ Waiting $WAIT_BETWEEN_STEPS_SEC before next VU step..."
            sleep $WAIT_BETWEEN_STEPS_SEC
        fi
    done
done
