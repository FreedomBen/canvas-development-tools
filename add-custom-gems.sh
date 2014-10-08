#!/bin/sh


# BEGIN-NOTICE

# Copyright (C) 2014  Benjamin Porter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# END-NOTICE

CUSTOM_GEM_FILE=Gemfile.d/ben.rb

die ()
{
    echo "[ERROR]: $0: $1"
    exit 1
}

[ -d Gemfile.d ] || die "Not in root of the canvas checkout (Could not find the dir Gemfile.d)"

cat << __EOF__ > $CUSTOM_GEM_FILE
gem 'awesome_print'
gem 'colorize'
gem 'wirb'
__EOF__

echo "Added these gems to $CUSTOM_GEM_FILE so they are available to your local instance:"
cat $CUSTOM_GEM_FILE
