#! /bin/bash
set -xe

echo 'Building site with Hugo...'
cd web && hugo

echo 'Deploying generated site to ducthanh98.github.io...'
cd ../ducthanh98.github.io
git add .
git diff-index --quiet HEAD || git commit -m 'Updating generated site'
git push origin main

echo 'Deploying source repository...'
cd ..
git add .
git diff-index --quiet HEAD || git commit -m 'Updating content and configuration'
git push origin main

echo 'Deploy completed successfully!'
