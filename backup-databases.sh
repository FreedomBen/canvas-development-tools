#!/usr/bin/env bash

DATE="$(date '+%d-%B-%Y')"
mkdir -p "$DATE"
cd "$DATE"

pg_dump "canvas_development" > "${DATE}-canvas_development.sql"
pg_dump "canvas_queue_development" > "${DATE}-canvas_queue_development.sql"
