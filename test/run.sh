#/bin/sh

pushd $(dirname $(dirname $BASH_SOURCE))

pub run test
