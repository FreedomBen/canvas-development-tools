#!/usr/bin/env bash

sudo useradd --no-create-home --uid 9999 dockeruser
sudo passwd -l dockeruser # no logging in as dockeruser
