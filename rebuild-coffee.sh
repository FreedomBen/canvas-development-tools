#!/bin/bash
if [ -n "$1" ]; then
  coffee -wo spec/javascripts/compiled/ spec/coffeescripts/
else
  coffee -wo public/javascripts/compiled/ app/coffeescripts/
fi
