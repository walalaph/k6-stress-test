# 📌 Function: Parses a K6 summary JSON and extracts key metrics as a TSV line
# ✅ Typically called after each VU test run to summarize results
# 🧪 Arguments:
#   $1 = path to the summary JSON file (from --summary-export)
#   $2 = API name (e.g., "test-login")
#   $3 = Number of VUs used in the run

parse_summary_json() {
  local json_file="$1"
  local api_name="$2"
  local vu="$3"

  jq -r --arg api "$api_name" --arg vu "$vu" '
    {
      api: $api,
      vu: $vu,
      iterations: (.metrics.iterations.count // 0),
      http_reqs: (.metrics.http_reqs.count // 0),
      error_pct: ((1 - .metrics.http_req_failed.value) * 100),
      duration_avg: (.metrics.http_req_duration.avg // 0),
      duration_p90: (.metrics.http_req_duration["p(90)"] // 0),
      duration_max: (.metrics.http_req_duration.max // 0),
      data_sent: (.metrics.data_sent.count // 0),
      data_recv: (.metrics.data_received.count // 0)
    } |
    [
      .api,
      .vu,
      .iterations,
      .http_reqs,
      (.error_pct | tostring + "%"),
      (.duration_avg | tostring),
      (.duration_p90 | tostring),
      (.duration_max | tostring),
      .data_sent,
      .data_recv
    ] | @tsv
  ' "$json_file"
}
