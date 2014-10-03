#!/bin/bash

# Colors made a little easier
restore='\033[0m'
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
light_gray='\033[0;37m'
dark_gray='\033[1;30m'
light_red='\033[1;31m'
light_green='\033[1;32m'
yellow='\033[1;33m'
light_blue='\033[1;34m'
light_purple='\033[1;35m'
light_cyan='\033[1;36m'
white='\033[1;37m'


MAINTAINER_EMAIL='bporter@instructure.com'
RUBY_VER='2.1.2'

canvasdir="$HOME"
canvaslocation="$canvasdir/canvas-lms"

error ()
{
    echo -e "${red}${1}${restore}" >&2
}

die ()
{
    error "$1" >&2
    exit 1
}

white ()
{
    echo -ne "${white}${1}${restore}"
}

green ()
{
    echo -ne "${green}${1}${restore}"
}

cyan ()
{
    echo -ne "${cyan}${1}${restore}"
}

red ()
{
    echo -ne "${red}${1}${restore}"
}

yellow ()
{
    echo -ne "${yellow}${1}${restore}"
}

runningOSX ()
{
    uname -a | grep "Darwin" > /dev/null 2>&1
}

runningFedora () 
{
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Fedora" > /dev/null 2>&1
    else
        uname -a | grep --color=auto "fc" > /dev/null 2>&1
    fi
}

runningUbuntu () 
{ 
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Ubuntu" > /dev/null 2>&1
    else
        uname -a | grep --color=auto "Ubuntu" > /dev/null 2>&1
    fi
}

runningArch ()
{
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep "Arch" >/dev/null 2>&1
    else
        uname -a | grep --color=auto "ARCH" > /dev/null 2>&1
    fi
}

runningMint ()
{
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Mint" > /dev/null 2>&1
    else
        return 1
    fi
}

# Derivatives like Mint and Elementary usually run the Ubuntu kernel so this can be an easy way to detect an Ubuntu derivative
runningUbuntuKernel ()
{
    uname -a | grep --color=auto "Ubuntu" > /dev/null 2>&1
}

runningWhat ()
{
    if runningOSX; then
        echo "Mac OS X"
    elif runningFedora; then
        echo "Fedora Linux"
    elif runningUbuntu; then
        echo "Ubuntu Linux"
    elif runningArch; then
        echo "Arch Linux"
    elif runningMint; then
        echo "Linux Mint"
    else
        echo "Unknown"
    fi
}

runningUnsupported ()
{
    if [ "$(runningWhat)" = "Unknown" ]; then
        return 0
    else
        return 1
    fi
}

chrubySupported ()
{
    if runningOSX; then
        return 0
    elif runningFedora; then
        return 1
    elif runningUbuntu; then
        return 1
    elif runningArch; then
        return 0
    elif runningMint; then
        return 1
    else
        return 1
    fi
}

rubyInstallSupported ()
{
    if runningOSX; then
        return 0
    elif runningFedora; then
        return 1
    elif runningUbuntu; then
        return 1
    elif runningArch; then
        return 0
    elif runningMint; then
        return 1
    else
        return 1
    fi
}

installDistroDependencies ()
{
    green "Installing any distro specific dependencies\n"

    if runningOSX; then
        if ! $(which gcc >/dev/null 2>&1); then
            cyan "We're going to install the OS X command line tools.  You will have to agree to Apple's terms\n"
            xcode-select --install
            cyan "Press <Enter> to continue after the command line tools are installed: "
        else
            green "XCode command line tools are installed\n"
        fi
    elif runningFedora; then
        sudo yum -y install ruby-devel libxml2-devel libxslt-devel libpqxx-devel sqlite-devel \
            postgresql postgresql-devel postgresql-server
    elif runningUbuntu; then
        sudo apt-get -y install ruby-dev zlib1g-dev rubygems1.9.1 libxml2-dev libxslt1-dev libsqlite3-dev \
            libhttpclient-ruby imagemagick libxmlsec1-dev python-software-properties postgresql \
            postgresql-contrib libpq-dev libpqxx-dev ruby-pg nodejs-legacy nodejs
    elif runningArch; then
        sudo pacman -S --needed --noconfirm lsb-release curl libxslt python2
    elif runningMint; then
        :
    else
        :
    fi
}

setLocale ()
{
    green "Setting locale\n"

    if runningArch && ! $(locale | grep "LANG=en_US.UTF-8" >/dev/null 2>&1); then
        cyan "Your locale is not currently set to en_US.UTF-8.\n"
        cyan "Press <Enter> and I'll change it for you, or Ctrl+C to quit\n"
        read
        sudo sh -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
        sudo locale-gen
        sudo sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
        . /etc/locale.conf
    fi
}

aurinstall ()
{
    green "Installing $1 from the aur\n"

    AUR_DIR="/tmp/aur"
    AUR_BUILD_DIR="$AUR_DIR/build"
    AUR_TARBALLS_DIR="$AUR_DIR/tarballs"

    mkdir -p "$AUR_BUILD_DIR"
    mkdir -p "$AUR_TARBALLS_DIR"

    prevdir="$(pwd)"

    cd "$AUR_TARBALLS_DIR"
    curl -L -O "$1"

    tarball="$(basename $1)"
    output_dir="$(echo $tarball | sed -e 's/\.tar.*//g')"
    cd "$AUR_BUILD_DIR"
    tar xf "$AUR_TARBALLS_DIR/$tarball"

    cd "$output_dir"
    ASROOT=''
    [ "$(id -u)" = 0 ] && ASROOT="--asroot"
    makepkg $ASROOT --clean --syncdeps --needed --noconfirm --install

    cd "$prevdir"
}

hasBrew ()
{
    if $(which brew >/dev/null 2>&1); then
        green "Brew is installed\n"
        return 0
    else
        yellow "Brew is NOT installed\n"
        return 1
    fi
}

installBrew ()
{
    green "Installing brew if necessary\n"

    if runningOSX; then
        if ! hasBrew; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            read -r -d '' VAR << "__EOF__"
# Added by canvas-lms setup-development script
# This adds the brew bin to your PATH
if $(which brew >/dev/null 2>&1); then
    export PATH="$PATH:$(brew --prefix)/bin"
fi
__EOF__

            yellow "You will need to have '$(brew --prefix)/bin\n in your PATH variable in order to run brew programs.\n"
            yellow "This can be done easily by adding these lines of code to ~/.bash_profile:\n\n"
            white "$VAR\n\n"
            yellow "Do this now?  (If not make sure you do it manually) (Y/N): "
            read addLines

            if [[ $addLines =~ [yY] ]]; then
                echo "" >> ~/.bash_profile
                echo "$VAR" >> ~/.bash_profile
            fi
        fi

        # make sure brew stuff is in our path
        if ! $(echo "$PATH" | sed -e 's/:/\n/g' | grep "$(brew --prefix)/bin" >/dev/null 2>&1); then
            yellow "Brew bin is not in PATH. Adding...\n"
            export PATH="$PATH:$(brew --prefix)/bin"   
            white "New PATH is '$PATH'\n"
        fi
        hasBrew
    fi
}

hasRuby ()
{
    if $(which ruby >/dev/null 2>&1); then
        green "Ruby is installed\n"
        return 0
    else
        yellow "Ruby is NOT installed\n"
        return 1
    fi
}

installRuby ()
{
    green "Installing ruby if necessary\n"

    if ! $(which ruby > /dev/null 2>&1); then
        if $(runningOSX); then
            brew install ruby
        elif $(runningFedora); then
            sudo yum -y install ruby
        elif $(runningUbuntu); then
            sudo apt-get -y install ruby
        elif $(runningArch); then
            sudo pacman -S --needed --noconfirm ruby
        elif $(runningMint); then
            sudo apt-get -y install ruby
        fi
    fi

    hasRuby
}

hasNodejs ()
{
    NODE=node
    NPM=npm

    if runningUbuntu || runningMint; then
        NODE=nodejs
    fi
        
    if $(which $NODE >/dev/null 2>&1) && $(which $NPM >/dev/null 2>&1); then
        green "Nodejs is installed\n"
        return 0
    else
        yellow "Nodejs is NOT installed\n"
        return 1
    fi
}

installNodejs ()
{
    green "Installing node.js if necessary\n"

    if ! hasNodejs; then
        if runningOSX; then
            brew install node
        elif runningFedora; then
            sudo yum -y install nodejs npm
        elif runningUbuntu; then
            sudo apt-get -y install nodejs npm
        elif runningArch; then
            sudo pacman -S --needed --noconfirm nodejs
        elif runningMint; then
            sudo apt-get -y install nodejs
        fi
    fi

    hasNodejs
}

hasChruby ()
{
    if $(type chruby 2>&1 | grep "chruby is a function" >/dev/null 2>&1); then
        green "Chruby is installed\n"
        return 0
    else
        yellow "Chruby is NOT installed\n"
        return 1
    fi
}

addChrubySourcingToFile ()
{
    green "Adding chruby sourcing to a bash startup file\n"

    f="$HOME/.bashrc"
    [ -n "$1" ] && f="$1"

    if [ -f "$f" ] && $(cat "$f" | egrep "Added by the canvas.lms setup script" >/dev/null 2>&1); then
         yellow "Bashrc already has sourcing commands for chruby\n"
    else
        echo "" >> "$f"
        echo "# Added by the canvas-lms setup script" >> "$f"
        echo "# These settings make chruby work" >> "$f"
        echo "# See https://github.com/postmodern/chruby" >> "$f"

        [ -f /usr/local/share/chruby/chruby.sh ] && \
            echo "[ -f /usr/local/share/chruby/chruby.sh ] && . /usr/local/share/chruby/chruby.sh" >> "$f"
        [ -f /usr/local/share/chruby/auto.sh ] && \
            echo "[ -f /usr/local/share/chruby/auto.sh ] && . /usr/local/share/chruby/auto.sh" >> "$f"
        [ -f /usr/share/chruby/chruby.sh ] && \
            echo "[ -f /usr/share/chruby/chruby.sh ] && . /usr/share/chruby/chruby.sh" >> "$f"
        [ -f /usr/share/chruby/auto.sh ] && \
            echo "[ -f /usr/share/chruby/auto.sh ] && . /usr/share/chruby/auto.sh" >> "$f"
        [ -f /usr/local/opt/chruby/share/chruby/chruby.sh ] && \
            echo "[ -f /usr/local/opt/chruby/share/chruby/chruby.sh ] && . /usr/local/opt/chruby/share/chruby/chruby.sh" >> "$f"
        [ -f /usr/local/opt/chruby/share/chruby/auto.sh ] && \
            echo "[ -f /usr/local/opt/chruby/share/chruby/auto.sh ] && . /usr/local/opt/chruby/share/chruby/auto.sh" >> "$f"
    fi
}

installChruby ()
{
    green "Installing chruby if necessary\n"

    # ruby-install is installed in a separate method
    if ! hasChruby; then
        if runningOSX; then
            brew install chruby
            addChrubySourcingToFile "$HOME/.bash_profile"
        elif runningFedora; then
            :
        elif runningUbuntu; then
            :
        elif runningArch; then
            aurinstall "https://aur.archlinux.org/packages/ch/chruby/chruby.tar.gz"
        elif runningMint; then
            :
        fi

        addChrubySourcingToFile

        # source now so chruby works immediately
        [ -f /usr/local/share/chruby/chruby.sh ] && . /usr/local/share/chruby/chruby.sh
        [ -f /usr/local/share/chruby/auto.sh ] && . /usr/local/share/chruby/auto.sh
        [ -f /usr/share/chruby/chruby.sh ] && . /usr/share/chruby/chruby.sh
        [ -f /usr/share/chruby/auto.sh ] && . /usr/share/chruby/auto.sh
    fi

    hasChruby
}

hasRubyinstall ()
{
    if $(which ruby-install >/dev/null 2>&1); then
        green "Ruby-install is installed\n"
        return 0
    else
        yellow "Ruby-install is NOT installed\n"
        return 1
    fi
}

installRubyinstall ()
{
    green "Installing ruby-install if necessary\n"

    if ! hasRubyinstall; then
        if runningOSX; then
            brew install ruby-install
        elif runningFedora; then
            :
        elif runningUbuntu; then
            :
        elif runningArch; then
            aurinstall "https://aur.archlinux.org/packages/ru/ruby-install-git/ruby-install-git.tar.gz"
        elif runningMint; then
            :
        fi
    fi

    hasRubyinstall
}

writeChrubyFile ()
{
    green "Writing chruby file to repo for version $CHRUBY_VERSION\n"

    CHRUBY_VERSION="ruby-$RUBY_VER"
    green "Writing Ruby version \"$CHRUBY_VERSION\" to file\n"
    echo "$CHRUBY_VERSION" > .ruby-version
}

hasPostgres ()
{
    if $(which psql >/dev/null 2>&1); then
        green "PostgreSQL is installed\n"
        return 0
    else
        yellow "PostgreSQL is NOT installed\n"
        return 1
    fi
}

installPostgres ()
{
    green "Installing PostgreSQL if necessary\n"

    if ! hasPostgres; then
        if runningOSX; then
            brew install postgresql
        elif runningFedora; then
            sudo yum -y install postgresql postgresql-devel postgresql-server
        elif runningUbuntu; then
            sudo apt-get -y install postgresql postgresql-contrib
        elif runningArch; then
            sudo pacman -S --needed --noconfirm postgresql
        elif runningMint; then
            sudo apt-get -y install postgresql postgresql-contrib
        fi
    fi

    hasPostgres
}

addPostgresUser()
{
    sudo mkdir -p /var/{lib,log}/postgres

    if ! runningOSX; then
        sudo useradd --no-create-home --system postgres
    fi

    if runningOSX; then
        sudo chown $(whoami) /var/{lib,log}/postgres
    else
        sudo chown postgres /var/{lib,log}/postgres
    fi
}

configurePostgres ()
{
    if ! hasPostgres; then
        installPostgres
    fi

    if ! hasPostgres; then
        red "Could not configure Postgres because it does not appear to be installed\n"
        return 1
    fi

    green "Configuring PostgreSQL\n"

    addPostgresUser

    if runningOSX; then
        initdb --locale en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
        pg_ctl -D /var/lib/postgres/data -l /var/log/postgres/server.log start
        pg_ctl -D /var/lib/postgres/data stop
    fi

    if runningFedora; then
        sudo postgresql-setup initdb        
        sudo systemctl start postgresql.service
    fi

    if runningArch; then
        # make sure there is a postgres user
        sudo -u postgres initdb --locale en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
        sudo -u postgres pg_ctl -D /var/lib/postgres/data -l /var/log/postgres/server.log start
    fi

    if runningUbuntu || runningMint; then
        sudo -u postgres service postgresql start
    fi

    if ! runningOSX; then
        # Give PG some time to start up ..
        cyan "Waiting 5 seconds for the PostgreSQL server to start...\n"
        sleep 5
        if ! $(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$(whoami)'" | grep "1" >/dev/null); then
            sudo -u postgres createuser --createdb --login --createrole --superuser --replication $(whoami)
        fi
    fi

    runningArch && sudo -u postgres pg_ctl -D /var/lib/postgres/data stop

    if runningArch || runningFedora; then
        sudo systemctl enable postgresql.service
    fi
}

postgresRunning ()
{
    if runningArch || runningFedora; then
        systemctl status postgresql.service
    elif runningUbuntu || runningMint; then
        service postgresql status
    else
        ps auxwww | grep -E "postgres\s-D" >/dev/null 2>&1
    fi

    if [ "$?" = "0" ]; then
        green "PostgreSQL server is running\n"
        return 0
    else
        yellow "PostgreSQL server is NOT running\n"
        return 1
    fi
}

startPostgres ()
{
    green "Starting PostgreSQL\n"

    if ! postgresRunning; then
        if runningArch || runningFedora; then
            sudo systemctl start postgresql
        elif runningUbuntu || runningMint; then
            sudo -u postgres service postgresl start
        else
            pg_ctl -D /var/lib/postgres/data -l /var/log/postgres/server.log start
        fi
    fi

    cyan "Waiting 5 seconds for the PostgreSQL server to start...\n"
    sleep 5

    postgresRunning
}

hasGit ()
{
    if $(which git >/dev/null 2>&1); then
        green "Git is installed\n"
        return 0
    else
        yellow "Git is NOT installed"
        return 1
    fi
}

installGit ()
{
    green "Installing git if necessary\n"

    if ! hasGit; then
        if runningOSX; then
            brew install git
        elif runningFedora; then
            sudo yum -y install git
        elif runningUbuntu; then
            sudo apt-get -y install git
        elif runningArch; then
            sudo pacman -S --needed --noconfirm git
        elif runningMint; then
            sudo apt-get -y install git
        fi
    fi

    hasGit
}

cloneCanvas ()
{
    green "Cloning canvas\n"

    cd "$canvasdir" 
    if [ -d canvas-lms ]; then 
        cyan "You may already have a canvas checkout (the directory exists).\n"
        cyan "Delete it and reclone? (Y/N): "
        read RESP
        if [[ $RESP =~ [Yy] ]]; then
            # For some reason we don't have permissions to delete some files
            # unless we use sudo  :(
            sudo rm -rf canvas-lms
        else
            return 0
        fi
    fi

    git clone $CLONE_URL
}

installNpmPackages ()
{
    green "Installing required npm assets\n"

    if runningArch; then
        # sudo $NPM install --python=python$(python2 --version 2>&1 | sed -e 's/Python //g')
        sudo $NPM install --python=python2
    else
        sudo $NPM install
    fi
}

buildCanvasAssets ()
{
    green "Compiling Canvas assets\n"
    bundle exec rake canvas:compile_assets
}

createDatabaseConfigFile ()
{
    green "Creating initial database config files\n"

    for c in amazon_s3 delayed_jobs domain file_store outgoing_mail security scribd external_migration database; do 
        cp -v "config/$c.yml.example" "config/$c.yml"
    done
}

databaseExists ()
{
    if $(psql -lqt | cut -d \| -f 1 | grep -w "$1" >/dev/null 2>&1); then
        green "PostgreSQL database '$1' exists\n"
        return 0
    else
        yellow "PostgreSQL database '$1' DOES NOT exist\n"
        return 1
    fi
}

createDatabases ()
{
    green "Creating initial databases if necessary\n"

    if $(which createdb >/dev/null 2>&1); then
        databaseExists "canvas_development" || createdb canvas_development
        databaseExists "canvas_queue_development" || createdb canvas_queue_development
        databaseExists "canvas_test" || createdb canvas_test
    else
        red "The binary 'createdb' is not in PATH.  Make sure PostgreSQL is installed correctly\n"
        return 1
    fi
}

populateDatabases ()
{
    createDatabases

    green "Populating initial databases\n"

    bundle exec rake db:initial_setup

    # Required for running tests
    if databaseExists "canvas_test"; then
        psql -c 'CREATE USER canvas' -d canvas_test
        psql -c 'GRANT ALL PRIVILEGES ON DATABASE canvas_test TO canvas' -d canvas_test
        psql -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO canvas' -d canvas_test
        psql -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO canvas' -d canvas_test
    else
        red "The test dabases \"canvas_test\" does not exist.  Could not set it up\n"
        return 1
    fi
}

hasCtags ()
{
    if $(which ctags >/dev/null 2>&1); then
        green "ctags is installed\n"
        return 0
    else
        yellow "ctags is NOT installed\n"
        return 1
    fi
}

installCtags ()
{
    green "Installing ctags if necessary\n"

    if ! hasCtags; then
        if runningOSX; then
            brew install ctags
        elif runningFedora; then
            sudo yum -y install ctags
        elif runningUbuntu; then
            sudo apt-get -y install ctags
        elif runningArch; then
            sudo pacman -S --needed --noconfirm ctags
        elif runningMint; then
            sudo apt-get -y install ctags
        fi
    fi
}

generateCtags ()
{
    hasCtags || installCtags

    green "Generating ctags tags file\n"

    if hasCtags; then
        green "Generating ctags tag file\n"
        ctags -R --exclude=.git --exclude=log --languages=ruby . $(bundle list --paths | xargs)
    fi
}

hasBundler ()
{
    if $(which bundler >/dev/null 2>&1); then
        green "Bundler is installed\n"
        return 0
    else
        yellow "Bundler is NOT installed\n"
        return 1
    fi
}

pathGems ()
{
    green "Making sure the gem location is in PATH\n"

    if ! $(echo $PATH | grep "$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')" >/dev/null 2>&1); then
        export PATH="$PATH:$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')/bin"
    fi
}

installBundler ()
{
    green "Installing bundler if necessary\n"

    pathGems

    # Install the latest version possible and set BUNDLE_VER
    # Try to read the bundler version straight from the gem file
    [ -f Gemfile.d/_before.rb ] && \
    BUNDLE_VER=$(ruby -e "$(cat Gemfile.d/_before.rb | grep required_bundler_version | head -1); puts \"#{required_bundler_version.last}\"")

    if [ -n "$BUNDLE_VER" ]; then
        green "Installing the bundle gem version $BUNDLE_VER\n"
        gem install bundler -v "$BUNDLE_VER" || \
            sudo gem install bundler -v "$BUNDLE_VER"
    elif ! hasBundler; then
        green "Installing the bundle gem newest version\n"
        gem install bundler || sudo gem install bundler
    fi
    
    hasBundler
}

installGems ()
{
    green "Installing bundler gems with bundle install (but no mysql)\n"

    pathGems

    # Patch required for building the thrift gem on OS X
    if runningOSX; then
        bundle config build.thrift "--with-cppflags=-D_FORTIFY_SOURCE=0"
    fi

    if [ -n "$BUNDLE_VER" ]; then
        bundle _${BUNDLE_VER}_ install --without mysql
    else
        bundle install --without mysql
    fi

    if [ "$?" != "0" ]; then
        if [ -z "$already_attempted" ] && $(bundle install --without mysql 2>&1 | grep "version .* is required" >/dev/null); then
            already_attempted=y
            BUNDLE_VER="$(bundle install --without mysql 2>&1 | awk '{print $3}')"

            if $(gem list --local | egrep "bundle.*," >/dev/null); then
                echo -e "${purple}Uninstalling bundler all${restore}\n"
                echo -e "3\ny\ny\ny\ny\ny\ny" | gem uninstall bundler
            else
                yes "Y" | gem uninstall bundler
            fi

            installBundler
            installGems # recursive
        fi
    fi
}

installRubyRI ()
{
    green "Installing ruby-install if necessary\n"

    ruby-install --no-reinstall ruby $RUBY_VER
    cd .
    ruby --version | grep "$(echo $RUBY_VER | sed -e 's/\./\\./g')" >/dev/null
}

addGerritHook ()
{
    green "Adding gerrit commit-msg hook\n"

    if ! [ -d .git/hooks ]; then 
        red "Could not add gerrit hook because the hooks dir is not where expected"
        return 1
    fi

    cat << "__EOF__" > .git/hooks/commit-msg
#!/bin/sh
# From Gerrit Code Review 2.8.5
#
# Part of Gerrit Code Review (http://code.google.com/p/gerrit/)
#
# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unset GREP_OPTIONS

CHANGE_ID_AFTER="Bug|Issue"
MSG="$1"

# Check for, and add if missing, a unique Change-Id
#
add_ChangeId() {
        clean_message=`sed -e '
                /^diff --git .*/{
                        s///
                        q
                }
                /^Signed-off-by:/d
                /^#/d
        ' "$MSG" | git stripspace`
        if test -z "$clean_message"
        then
                return
        fi

        if test "false" = "`git config --bool --get gerrit.createChangeId`"
        then
                return
        fi

        # Does Change-Id: already exist? if so, exit (no change).
        if grep -i '^Change-Id:' "$MSG" >/dev/null
        then
                return
        fi

        id=`_gen_ChangeId`
        T="$MSG.tmp.$$"
        AWK=awk
        if [ -x /usr/xpg4/bin/awk ]; then
                # Solaris AWK is just too broken
                AWK=/usr/xpg4/bin/awk
        fi

        # How this works:
        # - parse the commit message as (textLine+ blankLine*)*
        # - assume textLine+ to be a footer until proven otherwise
        # - exception: the first block is not footer (as it is the title)
        # - read textLine+ into a variable
        # - then count blankLines
        # - once the next textLine appears, print textLine+ blankLine* as these
        #   aren't footer
        # - in END, the last textLine+ block is available for footer parsing
        $AWK '
        BEGIN {
                # while we start with the assumption that textLine+
                # is a footer, the first block is not.
                isFooter = 0
                footerComment = 0
                blankLines = 0
        }

        # Skip lines starting with "#" without any spaces before it.
        /^#/ { next }

        # Skip the line starting with the diff command and everything after it,
        # up to the end of the file, assuming it is only patch data.
        # If more than one line before the diff was empty, strip all but one.
        /^diff --git / {
                blankLines = 0
                while (getline) { }
                next
        }

        # Count blank lines outside footer comments
        /^$/ && (footerComment == 0) {
                blankLines++
                next
        }

        # Catch footer comment
        /^\[[a-zA-Z0-9-]+:/ && (isFooter == 1) {
                footerComment = 1
        }

        /]$/ && (footerComment == 1) {
                footerComment = 2
        }

        # We have a non-blank line after blank lines. Handle this.
        (blankLines > 0) {
                print lines
                for (i = 0; i < blankLines; i++) {
                        print ""
                }

                lines = ""
                blankLines = 0
                isFooter = 1
                footerComment = 0
        }

        # Detect that the current block is not the footer
        (footerComment == 0) && (!/^\[?[a-zA-Z0-9-]+:/ || /^[a-zA-Z0-9-]+:\/\//) {
                isFooter = 0
        }

        {
                # We need this information about the current last comment line
                if (footerComment == 2) {
                        footerComment = 0
                }
                if (lines != "") {
                        lines = lines "\n";
                }
                lines = lines $0
        }

        # Footer handling:
        # If the last block is considered a footer, splice in the Change-Id at the
        # right place.
        # Look for the right place to inject Change-Id by considering
        # CHANGE_ID_AFTER. Keys listed in it (case insensitive) come first,
        # then Change-Id, then everything else (eg. Signed-off-by:).
        #
        # Otherwise just print the last block, a new line and the Change-Id as a
        # block of its own.
        END {
                unprinted = 1
                if (isFooter == 0) {
                        print lines "\n"
                        lines = ""
                }
                changeIdAfter = "^(" tolower("'"$CHANGE_ID_AFTER"'") "):"
                numlines = split(lines, footer, "\n")
                for (line = 1; line <= numlines; line++) {
                        if (unprinted && match(tolower(footer[line]), changeIdAfter) != 1) {
                                unprinted = 0
                                print "Change-Id: I'"$id"'"
                        }
                        print footer[line]
                }
                if (unprinted) {
                        print "Change-Id: I'"$id"'"
                }
        }' "$MSG" > "$T" && mv "$T" "$MSG" || rm -f "$T"
}
_gen_ChangeIdInput() {
        echo "tree `git write-tree`"
        if parent=`git rev-parse "HEAD^0" 2>/dev/null`
        then
                echo "parent $parent"
        fi
        echo "author `git var GIT_AUTHOR_IDENT`"
        echo "committer `git var GIT_COMMITTER_IDENT`"
        echo
        printf '%s' "$clean_message"
}
_gen_ChangeId() {
        _gen_ChangeIdInput |
        git hash-object -t commit --stdin
}


add_ChangeId

__EOF__

    [ -f .git/hooks/commit-msg ] && chmod +x .git/hooks/commit-msg
}

read -r -d '' VAR << __EOF__
${green}
Thank you for giving Canvas by Instructure a try!  Let's set up your development environment.

Please report bugs to $MAINTAINER_EMAIL.

We will do the following, in this order:

     1. Install brew package manager (if on Mac OS X)
     2. Install any distro specific dependencies we need
     3. Check and set the correct locale (needed for PostgreSQL)
     4. Set up and configure ruby
     5. Set up and configure Node.js/npm
     6. (Optionally) Set up and configure chruby and ruby-install for multiple ruby versions
     7. Set up and install PostgreSQL
     8. Install git
     9. Clone the canvas repo
    10. Set the chruby auto version (if chruby is installed)
    11. Install Bundler (into chruby environment if using chruby)
    12. run 'bundle install' on the repo to install canvas' required gems
    13. run 'npm install' to install required npm packages
    14. Build canvas assets
    15. Create a basic PostgreSQL database config file
    16. Start the PostgreSQL server and make sure it starts without error
    17. Create the necessary PostgreSQL databases for Canvas
    18. Populate the PostgreSQL databases
    19. Add the gerrit commit-msg hook to the repo (if cloning from gerrit)
    20. (Optionally) generate ctags and set a ruby version for use with chruby

You can run this script as many times as necessary on your system, to create as many clones of the canvas repo as you like
${restore}${yellow}
 * You will be prompted for input several times before the script is finished.
 * You will also need sudo access.
${restore}
__EOF__
echo -e "$VAR"

if [ "$(id -u)" = "0" ]; then
    red "You are running as root\n"
    red "You can continue as root, but all the repo files will be owned by root\n"
    red "It's recommended that you press Ctrl+C now and rerun this script as a normal user\n"
    read -p "Press <Enter> to continue or Ctrl+C to quit: " IGNORE
fi

if runningUnsupported; then
    die "Oh no!  You're using an OS I don't know how to support yet.  Please report this to $MAINTAINER_EMAIL"
fi

cyan "I see you're running $(runningWhat).  Is this correct? (Y/N): "
read RESP

if ! [[ $RESP =~ [Yy] ]]; then
    die "Oh no!  Please report this to $MAINTAINER_EMAIL"
fi

cyan "\nWhere do you want to clone canvas to (absolute path to a parent directory)?\n"
cyan "(Leave blank for default of $canvasdir): " 
read newcanvasdir

[ -n "$newcanvasdir" ] && canvasdir="$newcanvasdir"

mkdir -p "$canvasdir"
[ -d "$canvasdir" ] || die "Could not create directory \"$canvasdir\""

cyan "\nDo you work for Instructure? (If so we'll clone from gerrit, otherwise straight from Github) (Y/N): "
read WORKHERE

if [[ $WORKHERE =~ [Yy] ]]; then
    CLONE_URL='gerrit:canvas-lms'

    yellow "\nMake sure you read and complete the Gerrit setup instructions:\n\n    https://gollum.instructure.com/Using-Gerrit\n"
    green "\nSpecifically you need to:\n\n    1. Register with Gerrit\n    2. Setup SSH\n    3. Set your email address properly\n\n"
    cyan "Are you ready to continue (meaning you've done the Gerrit stuff above already)? <Press Enter>: "
    read

    if ! [ -f ~/.ssh/config ] || ! $(cat ~/.ssh/config | grep "Host gerrit" >/dev/null 2>&1); then
        red "\nI don't see gerrit information in your SSH config file :(\n"
        read -p "What is the gerrit server's hostname?: " GERR_HOSTNAME
        read -p "What is your gerrit server username?: " GERR_USERNAME
        read -p "What port number is gerrit listening on?: " GERR_PORTNUM

        if [ -n "$GERR_HOSTNAME" ] && [ -n "$GERR_USERNAME" ] && [ -n "$GERR_PORTNUM" ]; then
            CLONE_URL="ssh://${GERR_USERNAME}@${GERR_HOSTNAME}:${GERR_PORTNUM}/canvas-lms"
        else
            die "Incomplete gerrit information.  Please set up gerrit and try again"
        fi
    fi
else
    CLONE_URL='https://github.com/instructure/canvas-lms.git'
fi

if chrubySupported; then
    cyan "\nDo you want to use chruby and ruby-install (recommended)? (Y/N): "
    read CHRUBY
else
    CHRUBY=N
fi

cyan "\nDo you want to generate ctags? (Y/N): "
read CTAGS


installDistroDependencies
setLocale
installBrew || die "Error installing Home Brew on your system.  Please install manually and try again"
installRuby || die "Error installing Ruby on your system.  Please install manually and try again"
installNodejs || die "Error installing Node.js on your system.  Please install manually and try again"
[[ $CHRUBY =~ [Yy] ]] && { installChruby || die "Error installing Chruby on your system.  Please install manually and try again"; }
[[ $CHRUBY =~ [Yy] ]] && { installRubyinstall || die "Error installing Chruby on your system.  Please install manually and try again"; }
installPostgres || die "Error installing Postgres on your system.  Please install manually and try again"
configurePostgres || die "Error configuring Postgres on your system.  Please configure manually and try again"
installGit || die "Error installing Git on your system.  Please install manually and try again"
cloneCanvas || die "Error cloning Canvas.  Please check your network connection, and make sure you've completed gerrit setup (if you work for Instructure)"

# Move to the newly created canvas directory
cd "$canvaslocation" || die "Could not move to the newly cloned directory"

[[ $CHRUBY =~ [Yy] ]] && { writeChrubyFile || die "Error writing Chruby file to your repo.  Please install create the file manually and try again"; }
[[ $CHRUBY =~ [Yy] ]] && { installRubyRI || die "Error installing ruby with ruby-install.  Please try manually and run this script again"; }
installBundler || die "Error installing bundle.  Please install bundle manually and try again"
installGems || die "Error installing required gems.  Please run 'bundle install' manually and try again"
installNpmPackages || die "Error installing npm packages.  Please run 'npm install' manually and try again"
buildCanvasAssets || die "Error building Canvas assets.  Please build manually and try again"
createDatabaseConfigFile || die "Error creating the database config files"
startPostgres || die "Error starting PostgreSQL.  Please make sure it is installed and try again"
createDatabases || die "Error building the databases.  Please ensure PostgreSQL is installed and running and try again.  You may need to run 'sudo killall postgres' to nuke any running servers that are interfering"
populateDatabases || die "Error populating the databases"
[[ $WORKHERE =~ [Yy] ]] && { addGerritHook || red "Error adding Gerrit hook.  See https://gollum.instructure.com/Using-Gerrit#Cloning-a-repository\n"; }
[[ $CTAGS =~ [Yy] ]] && { generateCtags || red "Error generating ctags\n"; }

cyan "You made it!  Hope it wasn't too painful...\n"
cyan "You're system should now be ready for Canvas development.\n"
