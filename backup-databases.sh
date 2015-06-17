#!/usr/bin/env bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESTORE='\033[0m'

DATE_PRI="$(date '+%d-%B-%Y')"
DATE_ALT="$(date '+%d-%B-%Y-%s')" # useful when taking multiple backups per day

if [ -d "$DATE_PRI" ]; then
  DATE="$DATE_ALT"
else
  DATE="$DATE_PRI"
fi

mkdir -p "$DATE"
cd "$DATE"

for i in canvas_development canvas_queue_development; do
  outfile="${DATE}-${i}.sql"
  pg_dump "$i" > "$outfile"
  echo -e "${GREEN}* Backed up database $i to $outfile${RESTORE}"
  echo -e "${BLUE}    - Restore with 'psql $i < $outfile'${RESTORE}"
done
