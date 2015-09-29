#/bin/sh

pushd $(dirname $(dirname $BASH_SOURCE))

pub run test:test -p vm -p dartium

# pub run test:test -p vm -p dartium -r expanded -j 1
# pub run test:test -p vm -p dartium -r expanded -j 1
# pub run test test/test_runner_client_native_test.dart -j 1 -p chrome
# pub run test test/test_runner_client_native_test.dart -j 1 -r expanded -p dartium