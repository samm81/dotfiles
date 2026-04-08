#!/usr/bin/env bash
# unofficial strict mode
# note bash<=4.3 chokes on empty arrays with set -o nounset
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# https://sharats.me/posts/shell-script-best-practices/
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
shopt -s nullglob globstar

[[ "${TRACE:-0}" == '1' ]] && set -o xtrace

usage() {
  cat << 'EOF'
usage: scripts/nvim-profile <startup|gitcommit|diff|all> [--runs N] [--warmup N] [--out DIR] [--headless]

examples:
  scripts/nvim-profile startup
  scripts/nvim-profile startup --headless
  scripts/nvim-profile gitcommit --runs 20
  scripts/nvim-profile all --runs 10 --warmup 2
EOF
}

[[ "${1:-}" =~ ^-*h(e(l(p)?)?)?$ ]] && usage

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" > /dev/null 2>&1; then
    echo "missing required command: $cmd" >&2
    exit 1
  fi
}

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

scenario=""
runs=10
warmup=2
out_dir=""
mode="ui"

while [[ $# -gt 0 ]]; do
  case "$1" in
    startup | gitcommit | diff | all)
      scenario="$1"
      shift
      ;;
    --runs)
      runs="$2"
      shift 2
      ;;
    --warmup)
      warmup="$2"
      shift 2
      ;;
    --out)
      out_dir="$2"
      shift 2
      ;;
    --headless)
      mode="headless"
      shift
      ;;
    --ui)
      mode="ui"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$scenario" ]]; then
  usage >&2
  exit 1
fi

require_cmd nvim
require_cmd jq

timestamp=$(date +%Y%m%d-%H%M%S)
if [[ -z "$out_dir" ]]; then
  out_dir="${XDG_STATE_HOME:-$HOME/.local/state}/nvim/profile/$timestamp"
fi
mkdir -p "$out_dir"

shopt -s nullglob
quit_cmd="lua vim.schedule(function() vim.cmd('quitall') end)"

parse_startuptime() {
  local log_file="$1"

  jq -Rn '
    def round_ms:
      if . == null then null else (. * 1000 | round / 1000) end;

    def row:
      capture("^(?<clock>[0-9]+\\.[0-9]+)\\s+(?<elapsed>[0-9]+\\.[0-9]+)(?:\\s+(?<self>[0-9]+\\.[0-9]+))?:\\s(?<desc>.*)$")?;

    [inputs | row | select(.) | {
      clock_ms: (.clock | tonumber),
      elapsed_ms: (.elapsed | tonumber),
      self_ms: (if (.self // "") == "" then null else (.self | tonumber) end),
      desc: .desc
    }] as $rows
    | {
        first_screen_update_ms: (
          ($rows | map(select(.desc == "first screen update")) | last | .clock_ms?)
          | round_ms
        ),
        total_ms: (
          ($rows | map(select(.desc == "--- NVIM STARTED ---")) | last | .clock_ms?)
          // ($rows | last | .clock_ms?)
          | round_ms
        ),
        top_entries: (
          $rows
          | map(select(.desc | test("^require\\(|^sourcing |autocommands|editing files in windows")))
          | sort_by(.elapsed_ms)
          | reverse
          | .[:12]
          | map({
              clock_ms: (.clock_ms | round_ms),
              elapsed_ms: (.elapsed_ms | round_ms),
              desc
            })
        )
      }
  ' < "$log_file"
}

summarize_runs() {
  jq -s '
    def round_ms:
      if . == null then null else (. * 1000 | round / 1000) end;

    def percentile($p):
      sort as $a
      | if ($a | length) == 0 then
          null
        else
          $a[((((($a | length) - 1) * $p) / 100) | ceil)]
        end;

    def median:
      sort as $a
      | if ($a | length) == 0 then
          null
        elif ($a | length) % 2 == 1 then
          $a[(($a | length) / 2 | floor)]
        else
          (($a[(($a | length) / 2 | floor) - 1] + $a[(($a | length) / 2 | floor)]) / 2)
        end;

    def stats:
      {
        min: (min | round_ms),
        median: (median | round_ms),
        p95: (percentile(95) | round_ms),
        max: (max | round_ms)
      };

    . as $runs
    | ($runs | map(.total_ms)) as $totals
    | ($runs | map(.visible_ms) | map(select(. != null))) as $visible
    | ($runs | map(.probe.milestones // {})) as $milestone_runs
    | {
        scenario: ($runs[0].scenario // null),
        mode: ($runs[0].mode // null),
        runs: ($runs | length),
        visible_ms: (
          if ($visible | length) == 0 then
            null
          else
            ($visible | stats)
          end
        ),
        total_ms: ($totals | stats),
        milestones: (
          reduce $milestone_runs[] as $milestones ({};
            reduce ($milestones | keys_unsorted[]) as $key (.;
              .[$key] = ((.[$key] // []) + [($milestones[$key] | tonumber)])
            )
          )
          | with_entries(.value |= stats)
        ),
        representative_run: ($runs | sort_by(.visible_ms // .total_ms) | .[(length / 2 | floor)])
      }
  ' "$@"
}

print_summary() {
  local summary_file="$1"

  jq -r '
    def fmt:
      if . == null then "n/a" else tostring end;

    "scenario: \(.scenario)\n" +
    "mode: \(.mode)\n" +
    (if .visible_ms == null then "" else
      "first screen update ms: min \(.visible_ms.min | fmt)  median \(.visible_ms.median | fmt)  p95 \(.visible_ms.p95 | fmt)  max \(.visible_ms.max | fmt)\n"
    end) +
    "runs: \(.runs)\n" +
    "startup complete ms: min \(.total_ms.min | fmt)  median \(.total_ms.median | fmt)  p95 \(.total_ms.p95 | fmt)  max \(.total_ms.max | fmt)\n" +
    "slow entries from representative run:",
    (.representative_run.top_entries[:5][] | "  \(.elapsed_ms | fmt) ms  \(.desc)")
  ' "$summary_file"
}

run_nvim_for_scenario() {
  local current_scenario="$1"
  local probe_file="$2"
  local startuptime_file="$3"
  local tmpdir="$4"
  local -a nvim_args=(--startuptime "$startuptime_file" -c "$quit_cmd")

  if [[ "$mode" == "headless" ]]; then
    nvim_args=(--headless "${nvim_args[@]}")
  fi

  case "$current_scenario" in
    startup)
      NVIM_PROFILE_OUT="$probe_file" \
      NVIM_PROFILE_SCENARIO="$current_scenario" \
      NVIM_PROFILE_RUN_ID="$(basename "$probe_file" .probe.json)" \
      nvim "${nvim_args[@]}" > /dev/null 2>&1
      ;;
    gitcommit)
      mkdir -p "$tmpdir/repo/.git"
      cat > "$tmpdir/repo/COMMIT_EDITMSG" << 'EOF'
subject line

body line one
body line two
      EOF
      (
        cd "$tmpdir/repo"
        NVIM_PROFILE_OUT="$probe_file" \
        NVIM_PROFILE_SCENARIO="$current_scenario" \
        NVIM_PROFILE_RUN_ID="$(basename "$probe_file" .probe.json)" \
        nvim "${nvim_args[@]}" COMMIT_EDITMSG > /dev/null 2>&1
      )
      ;;
    diff)
      cat > "$tmpdir/left.txt" << 'EOF'
alpha
beta
gamma
delta
epsilon
zeta
EOF
      cat > "$tmpdir/right.txt" << 'EOF'
alpha
beta changed
gamma
delta
epsilon plus
zeta
eta
EOF
      NVIM_PROFILE_OUT="$probe_file" \
      NVIM_PROFILE_SCENARIO="$current_scenario" \
      NVIM_PROFILE_RUN_ID="$(basename "$probe_file" .probe.json)" \
      nvim "${nvim_args[@]}" -d "$tmpdir/left.txt" "$tmpdir/right.txt" > /dev/null 2>&1
      ;;
  esac
}

assert_run_shape() {
  local current_scenario="$1"
  local run_file="$2"

  case "$current_scenario" in
    gitcommit)
      jq -e '.probe.final.filetype == "gitcommit"' "$run_file" > /dev/null
      ;;
    diff)
      jq -e '.probe.final.any_diff_window == true and .probe.final.window_count >= 2' "$run_file" > /dev/null
      ;;
  esac
}

run_scenario() {
  local current_scenario="$1"
  local scenario_dir="$out_dir/$current_scenario"

  mkdir -p "$scenario_dir/raw" "$scenario_dir/logs"
  echo "benchmarking $current_scenario"

  local phase
  local index

  for phase in warmup run; do
    local limit="$warmup"
    if [[ "$phase" == "run" ]]; then
      limit="$runs"
    fi

    for ((index = 1; index <= limit; index++)); do
      local tmpdir
      local base
      local probe_file
      local parsed_file
      local startuptime_file
      local run_file

      tmpdir=$(mktemp -d)
      base="$phase-$index"
      probe_file="$scenario_dir/raw/$base.probe.json"
      parsed_file="$scenario_dir/raw/$base.startuptime.json"
      startuptime_file="$scenario_dir/logs/$base.startuptime.log"

      run_nvim_for_scenario "$current_scenario" "$probe_file" "$startuptime_file" "$tmpdir"
      parse_startuptime "$startuptime_file" > "$parsed_file"

      if [[ "$phase" == "run" ]]; then
        run_file="$scenario_dir/raw/result-$index.json"
        jq -s \
          --arg scenario "$current_scenario" \
          --arg mode "$mode" \
          --argjson run "$index" \
          '{
            scenario: $scenario,
            mode: $mode,
            run: $run,
            visible_ms: (if $mode == "ui" then .[0].first_screen_update_ms else null end),
            total_ms: .[0].total_ms,
            first_screen_update_ms: .[0].first_screen_update_ms,
            top_entries: .[0].top_entries,
            probe: .[1]
          }' \
          "$parsed_file" "$probe_file" > "$run_file"
        assert_run_shape "$current_scenario" "$run_file"
      fi

      rm -rf "$tmpdir"
    done
  done

  local run_files=("$scenario_dir"/raw/result-*.json)
  summarize_runs "${run_files[@]}" > "$scenario_dir/summary.json"
  print_summary "$scenario_dir/summary.json"
  echo "artifacts: $scenario_dir"
}

if [[ "$scenario" == "all" ]]; then
  run_scenario startup
  echo
  run_scenario gitcommit
  echo
  run_scenario diff
else
  run_scenario "$scenario"
fi

exit 0
