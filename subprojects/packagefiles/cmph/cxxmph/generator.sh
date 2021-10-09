#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
mkdir murmur-fix
cd murmur-fix
git clone --depth 1 https://github.com/aappleby/smhasher.git
cp smhasher/src/MurmurHash3.cpp .
rm -rf smhasher
