#!/bin/bash
set -e

/usr/local/bin/jazzy --config .jazzy.json --no-clean

github_user=$1
github_password=$2

cd Documentation/
rm -rf gh-pages
git clone -b gh-pages https://"$github_user":"$github_password"@github.com/gini/gini-pay-bank-sdk-ios.git gh-pages

rm -rf gh-pages/*
mkdir gh-pages/docs
cp -R Api/. gh-pages/docs/

cd gh-pages
touch .nojekyll

git add .
git commit -a -m 'Updated Gini Pay Bank SDK documentation'
git push

cd ..
rm -rf gh-pages/
