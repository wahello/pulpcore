#!/bin/bash

# This script expects all <app_label>-api.json files to exist in the plugins root directory.
# It produces a <app_label>-python-client.tar and <app_label>-python-client-docs.tar file in the plugins root directory.

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulpcore' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

set -mveuo pipefail

# make sure this script runs at the repo root
cd "$(dirname "$(realpath -e "$0")")"/../../..

pushd ../pulp-openapi-generator
rm -rf "pulpcore-client"

./gen-client.sh "../pulpcore/core-api.json" "core" python "pulpcore"

pushd pulpcore-client
python setup.py sdist bdist_wheel --python-tag py3

twine check "dist/pulpcore_client-"*"-py3-none-any.whl"
twine check "dist/pulpcore-client-"*".tar.gz"

tar cvf "../../pulpcore/core-python-client.tar" ./dist

find ./docs/* -exec sed -i 's/Back to README/Back to HOME/g' {} \;
find ./docs/* -exec sed -i 's/README//g' {} \;
cp README.md docs/index.md
sed -i 's/docs\///g' docs/index.md
find ./docs/* -exec sed -i 's/\.md//g' {} \;

cat >> mkdocs.yml << DOCSYAML
---
site_name: Pulpcore Client
site_description: Core bindings
site_author: Pulp Team
site_url: https://docs.pulpproject.org/pulpcore_client/
repo_name: pulp/pulpcore
repo_url: https://github.com/pulp/pulpcore
theme: readthedocs
DOCSYAML

# Building the bindings docs
mkdocs build

# Pack the built site.
tar cvf ../../pulpcore/core-python-client-docs.tar ./site
popd
popd
