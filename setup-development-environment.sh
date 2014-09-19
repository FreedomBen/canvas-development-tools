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
    echo -ne "${green}${1}${restore}"
}

blue ()
{
    echo -ne "${blue}${1}${restore}"
}

red ()
{
    echo -ne "${red}${1}${restore}"
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

installDistroDependencies ()
{
    green "Installing any distro specific dependencies\n"

    if runningOSX; then
        :
    elif runningFedora; then
        :
    elif runningUbuntu; then
        :
    elif runningArch; then
        sudo pacman -S --needed --noconfirm lsb-release 
    elif runningMint; then
        :
    else
        :
    fi
}

aurinstall ()
{
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
    which brew >/dev/null 2>&1
}

installBrew ()
{
    if runningOSX; then
        if ! hasBrew; then
            sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    which npm >/dev/null 2>&1
}

installNodejs ()
{
    if ! hasNodejs; then
        if runningOSX; then
            echo TODO
        elif runningFedora; then
            sudo yum -y install nodejs
        elif runningUbuntu; then
            sudo apt-get -y install nodejs
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
    which chruby >/dev/null 2>&1
}

installChruby ()
{
    if ! hasChruby; then
        if runningOSX; then
            brew install chruby
        elif runningFedora; then
            :
        elif runningUbuntu; then
            :
        elif runningArch; then
            aurinstall "https://aur.archlinux.org/packages/ch/chruby/chruby.tar.gz"
        elif runningMint; then
            :
        fi
    fi

    hasChruby
}

hasRubyinstall ()
{
    which ruby-install >/dev/null 2>&1
}

installRubyinstall ()
{
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
    RUBY_VERSION="ruby-2.1.2"
    green "Writing Ruby version \"$RUBY_VERSION\" to file\n"
    echo "$RUBY_VERSION" > .ruby-version
}

hasPostgres ()
{
    which psql >/dev/null 2>&1
}

installPostgres ()
{
    if ! hasPostgres; then
        if runningOSX; then
            echo TODO
        elif runningFedora; then
            sudo yum -y install postgresql
        elif runningUbuntu; then
            sudo apt-get -y install postgresql
        elif runningArch; then
            sudo pacman -S --needed --noconfirm postgresql
        elif runningMint; then
            sudo apt-get -y install postgresql
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
        if runningOSX; then
            echo TODO
        elif runningFedora; then
            sudo yum -y install ruby
        elif runningUbuntu; then
            sudo apt-get -y install ruby
        elif runningArch; then
            sudo pacman -S --needed --noconfirm ruby
        elif runningMint; then
            sudo apt-get -y install ruby
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
    green "Installing required npm assets\n"
    sudo npm install

    green "Compiling Canvas assets\n"
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
    green "Generating ctags tag file\n"
    ctags -R --exclude=.git --exclude=log --languages=ruby . $(bundle list --paths | xargs)
}

installBundle ()
{
    green "Installing the bundle gem\n"
    gem install bundle
}

installGems ()
{
    green "Installing bundler gems with bundle install (but no mysql)\n"
    bundle install --without mysql
}

read -r -d '' VAR << __EOF__
${green}
Thank you for giving Canvas by Instructure a try!  Let's set up your development environment.

Please report bugs to $MAINTAINER_EMAIL.

We will be doing the following:

     1. Setting up and configuring ruby
     2. Installing brew package manager (if on Mac OS X)
     3. Setting up and configuring chruby for multiple ruby versions
     4. Setting up and install PostgreSQL
     5. Installing git
     6. Cloning the canvas repo
     7. Building canvas assets
     8. Creating a basic database config file
     9. Creating the development and test databases for Canvas in PostgreSQL
    10. Optionally generate ctags and set a ruby version for use with chruby
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

blue "I see you're running $(runningWhat).  Is this correct? (Y/N): "
read RESP

if ! [[ $RESP =~ [Yy] ]]; then
    die "Oh no!  Please report this to $MAINTAINER_EMAIL"
fi

blue "You will need to have sudo access to continue.  You may be prompted several times for your password\n"

blue "Where do you want to clone canvas to (absolute path to a parent directory)?\n"
blue "(Leave blank for default of $canvasdir): " 
read newcanvasdir

[ -n "$newcanvasdir" ] && canvasdir="$newcanvasdir"

mkdir -p "$canvasdir"
[ -d "$canvasdir" ] || die "Could not create directory \"$canvasdir\""

blue "Do you want to use chruby (recommended)? (Y/N): "
read CHRUBY
blue "Do you want to generate ctags? (Y/N): "
read CTAGS

installDistroDependencies
installRuby || die "Error installing Ruby on your system.  Please install manually and try again"
installNodejs || die "Error installing Node.js on your system.  Please install manually and try again"
installBrew || die "Error installing Home Brew on your system.  Please install manually and try again"
if [[ $CHRUBY =~ [Yy] ]]; then installChruby || die "Error installing Chruby on your system.  Please install manually and try again"; fi
installPostgres || die "Error installing Postgres on your system.  Please install manually and try again"
installGit || die "Error installing Git on your system.  Please install manually and try again"
cloneCanvas || die "Error cloning Canvas.  Please install manually and try again"
cd "$canvaslocation" || die "Could not move to the newly cloned directory"
if [[ $CHRUBY =~ [Yy] ]]; then writeChruby || die "Error writing Chruby file to your repo.  Please install manually and try again"; fi
cd "$canvaslocation" || die "Could not move to the newly cloned directory"
installBundle || die "Error install bundle.  Please install bundle manually and try again"
installGems || die "Error installing required gems.  Please run 'bundle install' manually and try again"
buildCanvasAssets || die "Error building Canvas assets.  Please build manually and try again"
createDatabaseConfigFile || die "Error creating the database config files"
createDatabases || die "Error building the databases.  Please ensure PostgreSQL is installed and running and try again"
if [[ $CTAGS =~ [Yy] ]]; then generateCtags || die "Error generating ctags"; fi
