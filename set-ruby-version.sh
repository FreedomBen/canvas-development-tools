#!/bin/sh

die ()
{
    echo "[ERROR]: $1"
    exit 1
}

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

RUBY_VERSION="ruby-2.1.2"
echo "Writing Ruby version \"$RUBY_VERSION\" to file"
echo "$RUBY_VERSION" > .ruby-version
