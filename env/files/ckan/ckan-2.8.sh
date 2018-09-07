#!/bin/bash

source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan

git remote set-url origin https://github.com/ckan/ckan.git
git fetch
git clean -xdf
git reset --hard ckan-2.8.1

# upgrade python
pip install --upgrade -r requirements.txt
python setup.py develop

# upgrade ckan database schema
paster db upgrade -c /etc/ckan/default/production.ini