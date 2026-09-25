#!/usr/bin/env bash

set -euo pipefail

scripts_dir="$(cd "$(dirname "$0")" && pwd)"

bash "$scripts_dir/handle-icns.sh"
bash "$scripts_dir/handle-preview.sh"
bash "$scripts_dir/handle-readme.sh"
