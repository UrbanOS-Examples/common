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

# upgrade to latest scos theme
pip uninstall ckanext-scos-theme
pip install https://s3.us-east-2.amazonaws.com/os-build-artifacts-repository/scos-theme/ckanext-scos_theme-1.0.1.tar.gz

# upgrade ckan database schema
paster db upgrade -c /etc/ckan/default/production.ini

sudo systemctl restart apache2