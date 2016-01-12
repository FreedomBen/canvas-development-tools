#!/usr/bin/env bash

# This will be put into a more friendly script later

docker-compose build
docker-compose run --rm web bundle install && \
docker-compose run --rm web npm install && \
docker-compose run --rm web bundle exec rake canvas:compile_assets && \
cp docker-compose/config/* config/ && \
docker-compose run --rm web bundle exec rake db:create && \
docker-compose run --rm web bundle exec rake db:initial_setup

echo ""
echo "For the postgres container to work, you need to do:"
echo "     docker-compose up postgres"
echo "and let it initialize"
