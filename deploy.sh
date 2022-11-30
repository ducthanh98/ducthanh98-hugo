#! /bin/bash
set -xe

echo 'Building ...'
cd web && hugo -D
echo 'Committing'
cd .. && pwd && git add . &&  git commit -m'Updating ...'
cd ./ducthanh98.github.io && git add . && git commit -m'Updating ...'
echo 'Pushing ...'
cd .. && git push --recurse-submodules=on-demand
