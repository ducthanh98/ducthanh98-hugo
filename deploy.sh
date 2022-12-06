#! /bin/bash
set -xe

echo 'Building ...'
cd web && hugo -D
echo 'Committing'
cd .. && pwd && git add . &&  git commit -m'Updating ...' && git push origin main
cd ./ducthanh98.github.io && git add . && git commit -m'Updating ...' && git push origin main
