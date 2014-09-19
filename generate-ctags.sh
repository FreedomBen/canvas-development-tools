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


die ()
{
    echo "[ERROR]: $0: $1"
    exit 1
}

$(which bundle >/dev/null 2>&1) || die "Bundle cannot be found"
[ -d app ] || die "Are you in the root directory of your canvas checkout?"

echo "Generating ctags"
ctags -R --exclude=.git --exclude=log --languages=ruby . $(bundle list --paths | xargs)
