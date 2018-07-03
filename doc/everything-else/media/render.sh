#!/usr/bin/env bash
MEDIA_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${MEDIA_DIRECTORY}"

for file in *.dot
do
  dot -Tsvg -o "${file%.dot}.svg" "${file}"
done

git add .
