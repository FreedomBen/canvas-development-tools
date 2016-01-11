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
RUBY_VER='2.1.6'

canvasdir="$HOME"
checkoutname="canvas-lms"
canvaslocation="${canvasdir}/${checkoutname}"

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
    if runningArch; then
        cyan "If you haven't recently done a pacman -Syu then stuff might fail.  Run one now? (Y/[N]): "
        read PACMANSYU

        if [[ $PACMANSYU =~ [Yy] ]]; then
            sudo pacman -Syu
        fi
    fi

    green "Installing any distro specific dependencies\n"

    if runningOSX; then
        :
    elif runningFedora; then
        sudo dnf -y install ruby-devel
        sudo dnf -y install libxml2-devel
        sudo dnf -y install libxslt-devel
        sudo dnf -y install libpqxx-devel
        sudo dnf -y install sqlite-devel
        sudo dnf -y install postgresql
        sudo dnf -y install postgresql-devel
        sudo dnf -y install postgresql-server
    elif runningUbuntu; then
        sudo apt-get update
        green "Finished running 'apt-get update'.  Installing packages\n"
        sudo apt-get -y install ruby-dev
        sudo apt-get -y install zlib1g-dev
        sudo apt-get -y install rubygems1.9.1
        sudo apt-get -y install libxml2-dev
        sudo apt-get -y install libxslt1-dev
        sudo apt-get -y install libsqlite3-dev
        sudo apt-get -y install libhttpclient-ruby
        sudo apt-get -y install imagemagick
        sudo apt-get -y install libxmlsec1-dev
        sudo apt-get -y install python-software-properties
        sudo apt-get -y install postgresql
        sudo apt-get -y install postgresql-contrib
        sudo apt-get -y install libpq-dev
        sudo apt-get -y install libpqxx-dev
        sudo apt-get -y install ruby-pg
        sudo apt-get -y install build-essential
        sudo apt-get -y install libglib2.0
    elif runningArch; then
        sudo pacman -S --needed --noconfirm lsb-release
        sudo pacman -S --needed --noconfirm curl
        sudo pacman -S --needed --noconfirm libxslt
        sudo pacman -S --needed --noconfirm python2
    elif runningMint; then
        sudo apt-get update
        green "Finished running 'apt-get update'.  Installing packages\n"
        sudo apt-get -y install ruby-dev
        sudo apt-get -y install zlib1g-dev
        sudo apt-get -y install rubygems1.9.1
        sudo apt-get -y install libxml2-dev
        sudo apt-get -y install libxslt1-dev
        sudo apt-get -y install libsqlite3-dev
        sudo apt-get -y install libhttpclient-ruby
        sudo apt-get -y install imagemagick
        sudo apt-get -y install libxmlsec1-dev
        sudo apt-get -y install python-software-properties
        sudo apt-get -y install postgresql
        sudo apt-get -y install postgresql-contrib
        sudo apt-get -y install libpq-dev
        sudo apt-get -y install libpqxx-dev
        sudo apt-get -y install ruby-pg
        sudo apt-get -y install build-essential
        sudo apt-get -y install libglib2.0
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

askreinstallbrew ()
{
    cyan "\nBrew is already installed, but sometimes reinstalling it fixes errors."
    cyan "\nReinstall brew? (Y/[N]): "
    read REINSTALL

    if [[ $REINSTALL =~ [Yy] ]]; then
        return 0
    else
        return 1
    fi
}

installBrew ()
{
    green "Installing brew if necessary\n"

    if runningOSX; then
        if ! hasBrew || askreinstallbrew; then

            cyan "We're going to install the OS X command line tools through brew.  You will have to agree to Apple's terms\n"
            cyan "Please click the install button in the dialog that will be shown in a minute or so\n"
            cyan "Press <Enter> to continue: "
            read

            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            read -r -d '' VAR << "__EOF__"
# Added by canvas-lms setup-development script
# This adds the brew bin to your PATH
if $(which brew >/dev/null 2>&1); then
    export PATH="$PATH:$(brew --prefix)/bin"
fi
__EOF__

            yellow "\nYou will need to have '$(brew --prefix)/bin' in your PATH variable to run brew programs.\n"
            yellow "This can be done easily by adding these lines of code to '${HOME}/.bash_profile':\n\n"
            white "$VAR\n\n"
            yellow "Do this now?  (If not make sure you do it manually) ([Y]/N): "
            read addLines

            if ! [[ $addLines =~ [nN] ]]; then
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
            brew reinstall ruby
        elif $(runningFedora); then
            sudo dnf -y install ruby
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
            brew tap homebrew/versions
            brew reinstall node012
        else
            cyan "\nIn order to get the right version of node, we are going to\n"
            cyan "install nvm (see https://github.com/creationix/nvm#manual-install)\n"
            git clone https://github.com/creationix/nvm.git ~/.nvm && \
            cd ~/.nvm                                              && \
            git checkout `git describe --abbrev=0 --tags`          && {
                addNvmSourcingToFile
                sourceNvm
            }
        fi
    fi

    hasNodejs
}

addNvmSourcingToFile ()
{
    green "Adding nvm sourcing to a bash startup file\n"

    f="$HOME/.bashrc"
    [ -n "$1" ] && f="$1"

    if [ -f "$f" ] && $(cat "$f" | egrep "Added for nvm by the canvas.lms" >/dev/null 2>&1); then
         yellow "Bashrc already has sourcing commands for nvm\n"
    else
        cyan "\nFor nvm to work properly, it needs to be sourced by the shell.\n"
        cyan "I'll do this temporarily now, but you will need to add it to your\n"
        cyan "bashrc file for it to work automatically after you close this shell.\n"
        cyan "Should I add some lines to the end of your bashrc file so it works in the future? (Y/N): \n"
        read ADD_NVM_TO_BASHRC
        if [[ $ADD_NVM_TO_BASHRC =~ [Yy] ]]; then
            echo "" >> "$f"
            echo "# Added for nvm by the canvas-lms setup script" >> "$f"
            echo "# These settings make nvm work" >> "$f"
            echo "# See https://github.com/creationix/nvm#manual-install" >> "$f"
            echo 'export NVM_DIR="$HOME/.nvm"' >> "$f"
            echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> "$f"
        fi
    fi
}

sourceNvm ()
{
    # source now so nvm works immediately
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    hasNvm
}

hasNvm ()
{
    if $(type nvm 2>&1 | grep "nvm is a function" >/dev/null 2>&1); then
        green "nvm is installed\n"
        return 0
    else
        yellow "nvm is NOT installed\n"
        return 1
    fi
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

sourceChruby ()
{
    # source now so chruby works immediately
    [ -f /usr/local/share/chruby/chruby.sh ] && . /usr/local/share/chruby/chruby.sh
    [ -f /usr/local/share/chruby/auto.sh ] && . /usr/local/share/chruby/auto.sh
    [ -f /usr/share/chruby/chruby.sh ] && . /usr/share/chruby/chruby.sh
    [ -f /usr/share/chruby/auto.sh ] && . /usr/share/chruby/auto.sh

    hasChruby
}

installChruby ()
{
    green "Installing chruby if necessary\n"

    # ruby-install is installed in a separate method
    if ! hasChruby; then
        if runningOSX; then
            brew reinstall chruby
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

        sourceChruby
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
            brew reinstall ruby-install
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
            brew reinstall postgresql
        elif runningFedora; then
            sudo dnf -y install postgresql postgresql-devel postgresql-server
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
            sudo -u postgres service postgresql start
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
            brew reinstall git
        elif runningFedora; then
            sudo dnf -y install git
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
    green "Cloning canvas into '$canvaslocation'\n"

    cd "$canvasdir"
    if [ -d "$checkoutname" ]; then
        cyan "You may already have a canvas checkout (the directory exists).\n"
        cyan "Delete it and reclone? (Y/[N]): "
        read RESP
        if [[ $RESP =~ [Yy] ]]; then
            # For some reason we don't have permissions to delete some files
            # unless we use sudo  :(
            sudo rm -rf "$checkoutname"
        else
            return 0
        fi
    fi

    git clone "$CLONE_URL" "$checkoutname"
}

installNpmPackages ()
{
    green "Installing required npm assets\n"

    [ -n "$NPM" ] || NPM=npm

    if runningArch; then
        # sudo $NPM install --python=python$(python2 --version 2>&1 | sed -e 's/Python //g')
        $NPM install --python=python2 || {
            sudo chown $(whoami) -R "$HOME/.npm"
            $NPM install --python=python2
        }
    else
        $NPM install || {
            sudo chown $(whoami) -R "$HOME/.npm"
            $NPM install
        }
    fi
}

assetFailCheckContinue ()
{
    yellow "\nThe asset compilation failed.\n"
    yellow "You can continue setup but the assets will need to be\n"
    yellow "successfully built before you can run Canvas\n"
    yellow "(You build them with 'bundle exec rake canvas:compile_assets')\n"
    cyan "Continue with setup? ([Y]/N): "
    read CONTINUESETUP

    if [[ $CONTINUESETUP =~ [Nn] ]]; then
        return 1
    else
        return 0
    fi
}

buildCanvasAssets ()
{
    green "Compiling Canvas assets\n"
    bundle exec rake canvas:compile_assets || {
        yellow "The asset compilation failed.  This might be a permissions thing.\n"
        cyan "Re-run the compile with sudo? (Y/[N]): "
        read RECOMPILE

        if [[ $RECOMPILE =~ [yY] ]]; then
            pathGems
            sudo bundle exec rake canvas:compile_assets || {
                assetFailCheckContinue
                return $?
            }
        else
            assetFailCheckContinue
            return $?
        fi
    }
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
            brew reinstall ctags
        elif runningFedora; then
            sudo dnf -y install ctags
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

bashSource ()
{
    if runningOSX; then
        echo "${HOME}/.bash_profile"
    else
        echo "${HOME}/.bashrc"
    fi
}

pathGems ()
{
    green "Making sure the gem location is in PATH\n"

            read -r -d '' VAR << "__EOF__"
# Added by canvas-lms setup-development script
# This adds the gem bin to your PATH
if ! $(echo $PATH | grep "$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')/bin" >/dev/null 2>&1); then
    export PATH="$PATH:$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')/bin"
fi
__EOF__

    if ! $(echo $PATH | grep "$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')/bin" >/dev/null 2>&1); then
        export PATH="$PATH:$(gem env 'GEM_PATHS' | sed -e 's|:|/bin:|g')/bin"

        cyan "The Gems bin wasn't in your PATH.  I added it temporarily, but you may want to make it permanent\n"
        cyan "This can be done by adding these lines to '$(bashSource)':\n\n"
        echo "$VAR"
        cyan "\nDo this now? ([Y]/N): "
        read ADDLINES

        if ! [[ $ADDLINES =~ [nN] ]]; then
            echo "" >> "$(bashSource)"
            echo "$VAR" >> "$(bashSource)"
        fi
    fi
}

installBundler ()
{
    green "Installing bundler if necessary\n"

    pathGems

    # Install the latest version possible and set BUNDLE_VER
    # Try to read the bundler version straight from the gem file
    [ -f Gemfile.d/_before.rb ] && \
        BUNDLE_VER=$(ruby -e "$(cat Gemfile.d/_before.rb | grep req_bundler_version | head -1); puts \"#{req_bundler_version_ceiling}\"")

    if [ -n "$BUNDLE_VER" ]; then
        green "Installing the bundle gem version $BUNDLE_VER\n"
        gem install bundler -v "$BUNDLE_VER" || \
            { yellow "Installing bundler without sudo failed.  Trying again with sudo...\n"; sudo gem install bundler -v "$BUNDLE_VER"; }
    elif ! hasBundler; then
        green "Installing the bundle gem newest version\n"
        gem install bundler || { yellow "Installing bundler without sudo failed.  Trying again with sudo...\n"; sudo gem install bundler; }
    fi

    hasBundler
}

installGems ()
{
    green "Installing bundler gems with bundle install (but no mysql)\n"

    pathGems

    if runningOSX; then
        # Dependency required for building postgres extensions on OS X
        ARCHFLAGS="-arch x86_64" gem install pg || { yellow "Installing pg without sudo failed.  Trying again with sudo...\n"; sudo ARCHFLAGS="-arch x86_64" gem install pg; }
        # Patch required for building the thrift gem on OS X
        bundle config build.thrift "--with-cppflags=-D_FORTIFY_SOURCE=0"
    fi

    if [ -n "$BUNDLE_VER" ]; then
        bundle _${BUNDLE_VER}_ install --without mysql
    else
        bundle install --without mysql
    fi

    retval="$?"

    if [ "$retval" != "0" ]; then
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
        else
            return $retval
        fi
    fi
}

installRubyRI ()
{
    green "Installing ruby $RUBY_VER using ruby-install\n"

    sourceChruby

    if hasChruby; then
        ruby-install --no-reinstall ruby $RUBY_VER
        sourceChruby
        chruby $RUBY_VER
        ruby --version | grep "$(echo $RUBY_VER | sed -e 's/\./\\./g')" >/dev/null
    else
        red "Could not install ruby using ruby-install because chruby is not installed or found\n"
        return 1
    fi
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

is_full ()
{
    [ "$MODE" = "FULL" ]
}

is_clone ()
{
    is_full || [ "$MODE" = "CLONE" ]
}

is_install ()
{
    is_full || [ "$MODE" = "INSTALL" ]
}

read -r -d '' LOGO << "__EOF__"
----------------------------------------------------------------------

        /\ \           /\ \         /\ \         /\ \        / /\
       /  \ \         /  \ \       /  \ \____   /  \ \      / /  \
      / /\ \ \       / /\ \ \     / /\ \_____\ / /\ \ \    / / /\ \__
     / / /\ \ \     / / /\ \ \   / / /\/___  // / /\ \_\  / / /\ \___\
    / / /  \ \_\   / / /  \ \_\ / / /   / / // /_/_ \/_/  \ \ \ \/___/
   / / /    \/_/  / / /   / / // / /   / / // /____/\      \ \ \
  / / /          / / /   / / // / /   / / // /\____\/  _    \ \ \
 / / /________  / / /___/ / / \ \ \__/ / // / /______ /_/\__/ / /
/ / /_________\/ / /____\/ /   \ \___\/ // / /_______\\ \/___/ /
\/____________/\/_________/     \/_____/ \/__________/ \_____\/

----------------------------------------------------------------------

__EOF__

read -r -d '' INTRO << __EOF__
${green}

Thank you for giving Canvas by Instructure a try!  Let's set up your development environment.

Please report bugs to $MAINTAINER_EMAIL.
${restore}
__EOF__

read -r -d '' USAGE << __EOF__
${red}
Usage: $0 [mode]
${restore}${blue}
Modes:

    -f | --full     Installs all environment dependencies, clones and builds canvas (All steps)
    -i | --install  Installs all environment dependencies but does not clone canvas (Steps 1-8)
    -c | --clone    Clones and builds canvas (assumes all dependencies are installed (Step 9-20)
${restore}
__EOF__

read -r -d '' WHATWEDO << __EOF__
${green}
We will do the following, in this order:
${restore}
__EOF__

read -r -d '' INSTALL << __EOF__
     ${green}
     1. Install brew package manager (if on Mac OS X)
     2. Install any distro specific dependencies we need
     3. Check and set the correct locale (needed for PostgreSQL)
     4. Set up and configure ruby
     5. Set up and configure Node.js/npm
     6. (Optionally) Set up and configure chruby and ruby-install for multiple ruby versions
     7. Set up and install PostgreSQL
     8. Install git${restore}
__EOF__

read -r -d '' CLONE << __EOF__
${green}
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
    20. (Optionally) generate ctags and set a ruby version for use with chruby${restore}
__EOF__

read -r -d '' INFO << __EOF__
${yellow}

You can run this script as many times as necessary on your system, to create as many clones of the canvas repo as you like
${restore}${yellow}
 * You will be prompted for input several times before the script is finished.
 * You will also need sudo access.
${restore}
__EOF__


echo -en "${green}"
echo -n "${LOGO}"
echo -en "${restore}"
echo -en "${INTRO}"

# determine mode
if [[ "$1" =~ -f ]]; then
    MODE="FULL"
elif [[ "$1" =~ -i ]]; then
    MODE="INSTALL"
elif [[ "$1" =~ -c ]]; then
    MODE="CLONE"
else
    # usage
    echo -en "$USAGE"
    exit 1
fi

echo -en "$WHATWEDO"

is_install && echo -en "$INSTALL"
is_clone && echo -en "$CLONE"

echo -en "${INFO}"

if [ "$(id -u)" = "0" ]; then
    red "You are running as root\n"
    red "You can continue as root, but all the repo files will be owned by root\n"
    red "It's recommended that you press Ctrl+C now and rerun this script as a normal user\n"
    read -p "Press <Enter> to continue or Ctrl+C to quit: " IGNORE
fi

if runningUnsupported; then
    die "Oh no!  You're using an OS I don't know how to support yet.  Please report this to $MAINTAINER_EMAIL"
fi

cyan "I see you're running $(runningWhat).  Is this correct? ([Y]/N): "
read RESP

if [[ $RESP =~ [Nn] ]]; then
    die "Oh no!  Please report this to $MAINTAINER_EMAIL"
fi

if chrubySupported; then
    cyan "\nDo you want to use chruby and ruby-install (recommended)? (Y/[N]): "
    read CHRUBY
else
    CHRUBY=N
fi

if is_clone; then
    cyan "\nWhere do you want to clone canvas to (-absolute- path)?\n"
    cyan "(Leave blank for default of $canvaslocation): "
    read newcanvasdir

    # Support the ~ by replacing it with $HOME
    if $(echo "$newcanvasdir" | grep "^~" >/dev/null 2>&1); then
        if $(which ruby >/dev/null 2>&1); then
            newcanvasdir=$(ruby -e "print '$newcanvasdir'.sub '~', '$HOME'")
        else
            red "\nYou used a ~ in your path even though I told you it had to be absolute :-)\n"
            red "The problem is you don't have ruby installed so I can't fix it for you automatically.\n"
            cyan "Tell me again, but please don't use ~ in it again.\n"
            cyan "if you still use a ~ then you'll end up with canvas in a directory literally named '~': "
            read newcanvasdir
        fi
    fi

    if [ -n "$newcanvasdir" ]; then
        canvasdir="$(dirname $newcanvasdir)"
        canvaslocation="$newcanvasdir"
        checkoutname="$(echo $canvaslocation | sed -e 's/\/$//g' | sed -e 's/.*\///g')"
        green "Ok, we'll put canvas in $canvaslocation\n"
    fi

    mkdir -p "$canvasdir"
    [ -d "$canvasdir" ] || die "Could not create directory \"$canvasdir\""

    cyan "\nDo you work for Instructure? (If so we'll clone from gerrit, otherwise straight from Github) (Y/[N]): "
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

    cyan "\nDo you want to generate ctags? (Y/[N]): "
    read CTAGS
fi


if is_install; then
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
fi

if is_clone; then
    cloneCanvas || die "Error cloning Canvas.  Please check your network connection, and make sure you've completed gerrit setup (if you work for Instructure)"

    # Move to the newly created canvas directory
    cd "$canvaslocation" || die "Could not move to the newly cloned directory"

    [[ $CHRUBY =~ [Yy] ]] && { writeChrubyFile || die "Error writing Chruby file to your repo.  Please install create the file manually and try again"; }
    [[ $CHRUBY =~ [Yy] ]] && { installRubyRI || die "Error installing ruby with ruby-install.  Please try manually and run this script again (ruby-install ruby $RUBY_VER)"; }
    installBundler || die "Error installing bundle.  Please install bundle manually and try again"
    installGems || die "Error installing required gems.  Please run 'bundle install' manually and try again"
    installNpmPackages || die "Error installing npm packages.  Please run 'npm install' manually and try again"
    buildCanvasAssets || die "Error building Canvas assets.  Please build manually and try again (bundle exec rake canvas:compile_assets)"
    createDatabaseConfigFile || die "Error creating the database config files"
    startPostgres || die "Error starting PostgreSQL.  Please make sure it is installed and try again"
    createDatabases || die "Error building the databases.  Please ensure PostgreSQL is installed and running and try again.  You may need to run 'sudo killall postgres' to nuke any running servers that are interfering"
    populateDatabases || die "Error populating the databases"
    [[ $WORKHERE =~ [Yy] ]] && { addGerritHook || red "Error adding Gerrit hook.  See https://gollum.instructure.com/Using-Gerrit#Cloning-a-repository\n"; }
    [[ $CTAGS =~ [Yy] ]] && { generateCtags || red "Error generating ctags\n"; }
fi

cyan "You made it!  Hope it wasn't too painful...\n"
cyan "Your system should now be ready for Canvas development.\n"

# vim: set filetype=sh ts=4 sw=4 sts=4 expandtab :
