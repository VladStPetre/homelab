#!/usr/bin/env bash
set -euo pipefail

# Always talk to the local Docker Engine (avoid proxies / DOCKER_HOST overrides)
unset DOCKER_HOST
export DOCKER_HOST=unix:///var/run/docker.sock

# Parse stack name from SSH_ORIGINAL_COMMAND or first argument
STACK="${1:-}"
if [ -z "${STACK:-}" ] && [ -n "${SSH_ORIGINAL_COMMAND:-}" ]; then
  # Expect formats like: "verify mystack" or "mystack"
  read -r -a _argv <<<"$SSH_ORIGINAL_COMMAND"
  if [ "${_argv[0]}" = "verify" ] && [ "${#_argv[@]}" -ge 2 ]; then
    STACK="${_argv[1]}"
  else
    STACK="${_argv[0]}"
  fi
fi

if [ -z "${STACK:-}" ]; then
  echo "::error::Usage: verify <stack_name>"
  exit 64
fi

if ! command -v docker >/dev/null; then
  echo "::error::docker CLI not available on host"
  exit 127
fi

if ! docker stack ls --format '{{.Name}}' | grep -qx "$STACK"; then
  echo "::error::Stack '$STACK' not found on target"
  exit 2
fi

PER_SERVICE_TIMEOUT_SEC=600   # adjust as needed
SLEEP_BETWEEN_POLLS_SEC=5
failed_services=()

mapfile -t service_ids < <(docker stack services "$STACK" -q)
if [ "${#service_ids[@]}" -eq 0 ]; then
  echo "::error::Stack '$STACK' has no services"
  exit 3
fi

now_ts() { date +%s; }

echo "Verifying rollout for stack: $STACK"
for sid in "${service_ids[@]}"; do
  sname="$(docker service inspect -f '{{.Spec.Name}}' "$sid")" || sname="$sid"
  desired_replicas="$(docker service inspect -f '{{if .Spec.Mode.Replicated}}{{.Spec.Mode.Replicated.Replicas}}{{else}}1{{end}}' "$sid")"
  spec_image="$(docker service inspect -f '{{.Spec.TaskTemplate.ContainerSpec.Image}}' "$sid")"

  echo "• Service: $sname (desired replicas: $desired_replicas)"
  start="$(now_ts)"
  ok=0

  while :; do
    running_cnt="$(docker service ps "$sid" --filter desired-state=running --format '{{.CurrentState}}' | grep -c '^Running' || true)"
    failed_cnt="$(docker service ps "$sid" --no-trunc --format '{{.CurrentState}} {{.Error}}' | \
      awk '/(Failed|Rejected|Shutdown|Complete)/ && $0 !~ /Running/ {c++} END{print c+0}')"

    mismatch_cnt=0
    while IFS= read -r tid; do
      timg="$(docker inspect "$tid" -f '{{.Spec.ContainerSpec.Image}}' || true)"
      if [ -n "$timg" ] && [ "$timg" != "$spec_image" ]; then
        mismatch_cnt=$((mismatch_cnt+1))
      fi
    done < <(docker service ps "$sid" -q --no-trunc)

    if [ "$running_cnt" = "$desired_replicas" ] && [ "$failed_cnt" = "0" ] && [ "$mismatch_cnt" = "0" ]; then
      ok=1; break
    fi

    elapsed=$(( $(now_ts) - start ))
    if [ "$elapsed" -ge "$PER_SERVICE_TIMEOUT_SEC" ]; then
      echo "::warning::Timeout waiting for $sname to converge"
      break
    fi
    sleep "$SLEEP_BETWEEN_POLLS_SEC"
  done

  if [ "$ok" -eq 1 ]; then
    echo "  ✓ Converged: $sname → $spec_image"
  else
    echo "  ✗ Not converged: $sname"
    echo "    — Spec image: $spec_image"
    echo "    — Status snapshot:"
    docker service ps "$sid" --no-trunc --format '      {{.ID}}  {{.Name}}  {{.CurrentState}}  {{.Error}}  {{.Image}}' | tail -n 20 || true
    upd_state="$(docker service inspect -f '{{with .UpdateStatus}}{{.State}}: {{.Message}}{{end}}' "$sid")" || true
    if [ -n "$upd_state" ]; then
      echo "    — UpdateStatus: $upd_state"
    fi
    failed_services+=("$sname")
  fi
done

if [ "${#failed_services[@]}" -gt 0 ]; then
  echo ""
  echo "::error::The following services failed rollout: ${failed_services[*]}"
  exit 4
fi

echo "All services converged successfully."
