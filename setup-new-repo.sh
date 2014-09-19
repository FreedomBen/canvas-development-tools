#!/bin/bash


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


scripts=('add-custom-gems.sh' 'generate-ctags.sh' 'create-database-config.sh' 'initialize-databases.sh' 'build-assets')
abs_path="$HOME/gitclone/canvas-development-tools"
set_ruby_version="$abs_path/set-ruby-version.sh"

die ()
{
    echo "[ERROR]: $0: $1"
    exit 1
}

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

[ -x "$set_ruby_version" ] || die "Could not find $set_ruby_version"
$set_ruby_version

cd .  # reload chruby settings now that we have a ruby version
gem install bundle
bundle install --without mysql
bundle update

for i in ${scripts[@]}; do
    echo "Running $i"
    full_path="$abs_path/$i"
    [ -x "$full_path" ] && $full_path
done

echo "Setup is complete.  You may see database creation errors if this is not the first Canvas you've set up on this system."
