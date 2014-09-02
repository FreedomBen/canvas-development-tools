#!/bin/sh

die ()
{
    echo "[ERROR]: $0: $1"
    exit 1
}

[ -d app ] || die "Not in correct place.  Are you in the root of the canvas checkout?"

$(which npm >/dev/null 2>&1) || die "npm is not installed.  Cannot build assets"
$(which bundle >/dev/null 2>&1) || die "bundle is not installed.  Cannot build assets"

echo "Running \"npm install\""
npm install

echo "Compiling assets..."
bundle exec rake canvas:compile_assets
