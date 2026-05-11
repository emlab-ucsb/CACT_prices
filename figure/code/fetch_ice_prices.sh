#!/usr/bin/env bash
# Proof of concept: pull California Carbon Allowance Vintage 2026 daily
# settlement prices from ICE's public product-guide JSON API and write CSVs.
#
# Endpoints discovered from https://www.ice.com/products/82612870/...:
#   contract-data : latest quote per listed contract month (productId=CCA Futures)
#   data/historical: daily settlement series for one contract month (by marketId)
set -euo pipefail

OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../input" && pwd)"
UA="Mozilla/5.0 (compatible; CACT-prices-bot/1.0; +https://github.com/emlab-ucsb/cact_prices)"
SPAN=3   # ICE historical span: 3 = longest available daily history

# contract label -> ICE marketId  (May 2026 and Dec 2026 deliveries)
declare -A MARKETS=(
  [may26]=8042248
  [dec26]=7143176
)

fetch_history() {
  local market_id="$1" out_file="$2"
  echo "fetching marketId=${market_id} -> ${out_file}"
  curl -sS --fail -A "$UA" \
    "https://www.ice.com/marketdata/api/productguide/charting/data/historical?marketId=${market_id}&historicalSpan=${SPAN}" \
  | jq -r '
      "date,settlement_price",
      (.bars[]
       | [ (.[0] | strptime("%a %b %d %H:%M:%S %Y") | strftime("%Y-%m-%d")), .[1] ]
       | @csv)
    ' > "$out_file"
  echo "  wrote $(( $(wc -l < "$out_file") - 1 )) rows"
}

for label in "${!MARKETS[@]}"; do
  fetch_history "${MARKETS[$label]}" "${OUT_DIR}/cca_v26_${label}_ice.csv"
done

echo "done."
