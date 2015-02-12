if ! $(which google-chrome >/dev/null 2>&1); then
  if $(which google-chrome-stable >/dev/null 2>&1); then
    export CHROME_BIN="$(which google-chrome-stable)"
  elif $(which google-chrome-unstable >/dev/null 2>&1); then
    export CHROME_BIN="$(which google-chrome-unstable)"
  fi
  echo "Chrome is at: $CHROME_BIN"
fi

if [ -n "$1" ]; then
  export JS_SPEC_MATCHER="$1"
  echo "Running specs matching '$JS_SPEC_MATCHER'"
fi

bundle exec rake js:dev
