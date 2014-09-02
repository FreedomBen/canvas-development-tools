#!/bin/sh

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

createdb canvas_development
createdb canvas_queue_development

