#!/bin/sh
set -e
script_dir=$(cd $(dirname $0);pwd)
ROOT=$(dirname $script_dir)
apps_dir=$ROOT/apps
packages_dir=$ROOT/packages
package_name=isolate_transformer
organization=com.aoeiuv020.flutter.isolatetransformer
app_name=example