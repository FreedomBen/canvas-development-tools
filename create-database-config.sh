#!/bin/sh

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

for config in "amazon_s3 delayed_jobs domain file_store outgoing_mail security scribd external_migration"; do 
    cp -v config/$config.yml.example config/$config.yml; 
done

cp config/database.yml.example config/database.yml

