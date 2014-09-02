#!/bin/sh

[ -d config ] || die "Are you in the root directory of your canvas checkout?"

for c in amazon_s3 delayed_jobs domain file_store outgoing_mail security scribd external_migration database; do 
    cp -v "config/$c.yml.example" "config/$c.yml"
done

