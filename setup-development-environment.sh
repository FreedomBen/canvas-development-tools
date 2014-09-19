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

green ()
{
    echo -e "${green}${1}${restore}"
}

runningOSX ()
{
    uname -a | grep "Darwin" > /dev/null
}

runningFedora () 
{ 
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Fedora" > /dev/null
    else
        uname -a | grep --color=auto "fc" > /dev/null
    fi
}

runningUbuntu () 
{ 
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Ubuntu" > /dev/null
    else
        uname -a | grep --color=auto "Ubuntu" > /dev/null
    fi
}

runningArch ()
{
    if $(which lsb_release); then
        lsb_release -d | grep "Arch" >/dev/null
    else
        uname -a | grep --color=auto "ARCH" > /dev/null
    fi
}

runningMint ()
{
    if $(which lsb_release >/dev/null 2>&1); then
        lsb_release -d | grep --color=auto "Mint" > /dev/null
    else
        return 1
    fi
}

# Derivatives like Mint and Elementary usually run the Ubuntu kernel so this can be an easy way to detect an Ubuntu derivative
runningUbuntuKernel ()
{
    uname -a | grep --color=auto "Ubuntu" > /dev/null
}

runningWhat ()
{
    if $(runningOSX); then
        echo "Mac OS X"
    elif $(runningFedora); then
        echo "Fedora Linux"
    elif $(runningUbuntu); then
        echo "Ubuntu Linux"
    elif $(runningArch); then
        echo "Arch Linux"
    elif $(runningMint); then
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

installDistroDependencies ()
{
    green "Installing any distro specific dependencies"

    if $(runningOSX); then
        :
    elif $(runningFedora); then
        :
    elif $(runningUbuntu); then
        :
    elif $(runningArch); then
        pacman -S --needed --noconfirm lsb-release 
    elif $(runningMint); then
        :
    else
        :
    fi
}

hasBrew ()
{
    which brew >/dev/null 2>&1
}

installBrew ()
{
    if runningOSX; then
        if ! hasBrew; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi

        hasBrew
    fi
}

hasRuby ()
{
    which ruby >/dev/null 2>&1
}

installRuby ()
{
    if ! $(which ruby > /dev/null 2>&1); then
        if $(runningOSX); then
            echo TODO
        elif $(runningFedora); then
            yum -y install ruby
        elif $(runningUbuntu); then
            apt-get -y install ruby
        elif $(runningArch); then
            pacman -S --needed --noconfirm ruby
        elif $(runningMint); then
            apt-get -y install ruby
        fi
    fi

    hasRuby
}

hasNodejs ()
{
    which npm >/dev/null 2>&1
}

installNodejs ()
{
    if ! hasNodejs; then
        if $(runningOSX); then
            echo TODO
        elif $(runningFedora); then
            yum -y install nodejs
        elif $(runningUbuntu); then
            apt-get -y install nodejs
        elif $(runningArch); then
            pacman -S --needed --noconfirm nodejs
        elif $(runningMint); then
            apt-get -y install nodejs
        fi
    fi

    hasNodejs
}

hasChruby ()
{
    which chruby >/dev/null 2>&1
}

installChruby ()
{
    return 1
    hasChruby
}

writeChrubyFile ()
{
    RUBY_VERSION="ruby-2.1.2"
    green "Writing Ruby version \"$RUBY_VERSION\" to file"
    echo "$RUBY_VERSION" > .ruby-version
}

hasPostgres ()
{
    which psql >/dev/null 2>&1
}

installPostgres ()
{
    if ! hasPostgres; then
        if $(runningOSX); then
            echo TODO
        elif $(runningFedora); then
            yum -y install postgresql
        elif $(runningUbuntu); then
            apt-get -y install postgresql
        elif $(runningArch); then
            pacman -S --needed --noconfirm postgresql
        elif $(runningMint); then
            apt-get -y install postgresql
        fi
    fi

    hasPostgres
}

hasGit ()
{
    which git >/dev/null 2>&1
}

installGit ()
{
    if ! hasGit; then
        if $(runningOSX); then
            echo TODO
        elif $(runningFedora); then
            yum -y install ruby
        elif $(runningUbuntu); then
            apt-get -y install ruby
        elif $(runningArch); then
            pacman -S --needed --noconfirm ruby
        elif $(runningMint); then
            apt-get -y install ruby
        fi
    fi

    hasGit
}

cloneCanvas ()
{
    cd "$canvasdir" && git clone https://github.com/instructure/canvas-lms.git
}

buildCanvasAssets ()
{
    green "Installing required npm assets"
    npm install

    green "Compiling Canvas assets"
    bundle exec rake canvas:compile_assets
}

createDatabaseConfigFile ()
{
    for c in amazon_s3 delayed_jobs domain file_store outgoing_mail security scribd external_migration database; do 
        cp -v "config/$c.yml.example" "config/$c.yml"
    done
}

createDatabases ()
{
    if $(which createdb >/dev/null 2>&1); then
        createdb canvas_development
        createdb canvas_queue_development
    else
        return 1
    fi
}

generateCtags ()
{
    green "Generating ctags tag file"
    ctags -R --exclude=.git --exclude=log --languages=ruby . $(bundle list --paths | xargs)
}

installBundle ()
{
    green "Installing the bundle gem"
    gem install bundle
}

installGems ()
{
    green "Installing bundler gems with bundle install (but no mysql)"
    bundle install --without mysql
}

cat << __EOF__

Thank you for giving Canvas by Instructure a try!  Let's set up your development environment.

Please report bugs to $MAINTAINER_EMAIL.

We will be doing the following:

     1. Setup and configure ruby
     2. Install brew package manager (if on Mac OS X)
     3. Setup and configure chruby for multiple ruby versions
     4. Setup and install PostgreSQL
     5. Install git
     6. Clone the canvas repo
     7. Build canvas assets
     8. Create a basic database config file
     9. Create the development and test databases for Canvas in PostgreSQL
    10. Optionally generate ctags and set a ruby version for use with chruby

__EOF__


if [ "$(id -u)" != "0" ]; then
    error "Oh no!  You need to be root to run this script because we install a bunch of stuff."
    die "You may try re-running this script with sudo:  sudo $0"
    exit 1
fi

if runningUnsupported; then
    die "Oh no!  You're using an OS I don't know how to support yet.  Please report this to $MAINTAINER_EMAIL"
fi

read -p "I see you're currently running $(runningWhat).  Is this correct? (Y/N): " RESP

if ! [[ $RESP =~ [Yy] ]]; then
    die "Oh no!  Please report this to $MAINTAINER_EMAIL"
fi

echo "To where do you want to clone canvas (absolute path to a parent directory)? "
read -p "(Leave blank for default of $canvasdir)" canvasdir
mkdir -p "$canvasdir"
[ -d "$canvasdir" ] || die "Could not create directory \"$canvasdir\""

read -p "Do you want to use chruby (recommended)? (Y/N): " CHRUBY
read -p "Do you want to generate ctags? (Y/N): " CTAGS

installDistroDependencies
installRuby || die "Error installing Ruby on your system.  Please install manually and try again"
installNodjes || die "Error installing Node.js on your system.  Please install manually and try again"
installBrew || die "Error installing Home Brew on your system.  Please install manually and try again"
[[ $CHRUBY =~ [Yy] ]] && (installChruby || die "Error installing Chruby on your system.  Please install manually and try again")
installPostgres || die "Error installing Postgres on your system.  Please install manually and try again"
installGit || die "Error installing Git on your system.  Please install manually and try again"
cloneCanvas || die "Error cloning Canvas.  Please install manually and try again"
cd "$canvaslocation" || die "Could not move to the newly cloned directory"
[[ $CHRUBY =~ [Yy] ]] && (writeChruby || die "Error writing Chruby file to your repo.  Please install manually and try again")
cd "$canvaslocation" || die "Could not move to the newly cloned directory"
installBundle || die "Error install bundle.  Please install bundle manually and try again"
installGems || die "Error installing required gems.  Please run 'bundle install' manually and try again"
buildCanvasAssets || die "Error building Canvas assets.  Please build manually and try again"
createDatabaseConfigFile || die "Error creating the database config files"
createDatabases || die "Error building the databases.  Please ensure PostgreSQL is installed and running and try again"
[[ $CTAGS =~ [Yy] ]] && (generateCtags || die "Error generating ctags")
