#!/bin/sh

ctags -R --exclude=.git --exclude=log --languages=ruby . ~/gitclone/canvas-lms/gems/ ~/.gem/ruby/2.1.2/
