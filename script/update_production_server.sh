#!/usr/bin/env bash

set -Eeuo pipefail

SERVICE_NAME="puma-hitguessr"
RAILS_ENVIRONMENT="production"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOCK_FILE="/tmp/update_hitguessr.lock"

exec 200>"${LOCK_FILE}"
if ! flock -n 200; then
	echo "A deployment is already in progress (lock: ${LOCK_FILE})."
	exit 1
fi

cd "${ROOT_DIR}"

service_stopped=false

cleanup() {
	local exit_code=$?
	if [[ ${exit_code} -ne 0 ]]; then
		echo "Error detected (code ${exit_code})."
		if [[ "${service_stopped}" == "true" ]]; then
			echo "Attempting to restart ${SERVICE_NAME}..."
			sudo systemctl start "${SERVICE_NAME}" || true
		fi
	fi
}
trap cleanup EXIT

echo "[1/6] Stopping service ${SERVICE_NAME}..."
sudo systemctl stop "${SERVICE_NAME}"
service_stopped=true

echo "[2/6] Updating master branch (fast-forward only)..."
git fetch --all --prune
git checkout master
git pull --ff-only

echo "[3/6] Installing Ruby dependencies (if needed)..."
bundle install

echo "[4/6] Precompiling JavaScript/CSS assets in ${RAILS_ENVIRONMENT}..."
RAILS_ENV="${RAILS_ENVIRONMENT}" bundle exec rails assets:precompile

echo "[5/6] Running migrations in ${RAILS_ENVIRONMENT}..."
RAILS_ENV="${RAILS_ENVIRONMENT}" bin/rails db:migrate

echo "[6/6] Starting service ${SERVICE_NAME}..."
sudo systemctl start "${SERVICE_NAME}"
service_stopped=false

echo "Checking service status..."
sudo systemctl is-active --quiet "${SERVICE_NAME}"

echo "Update completed ✅"
