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
        :
    elif runningFedora; then
        :
    elif runningUbuntu; then
        :
    elif runningArch; then
        sudo pacman -S --needed --noconfirm lsb-release
        sudo pacman -S --needed --noconfirm curl
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
    if runningOSX; then
        if ! hasBrew; then
            sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    if $(which npm >/dev/null 2>&1); then
        green "Nodejs is installed\n"
        return 0
    else
        yellow "Nodejs is NOT installed\n"
        return 1
    fi
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
    if $(type chruby | grep "chruby is a function" >/dev/null 2>&1); then
        green "Chruby is installed\n"
        return 0
    else
        yellow "Chruby is NOT installed\n"
        return 1
    fi
}

installChruby ()
{
    # ruby-install is installed in a separate method
    if ! hasChruby; then
        if runningOSX; then
            brew install chruby
            echo ". /usr/local/share/chruby/chruby.sh" >> ~/.bash_profile
        elif runningFedora; then
            :
        elif runningUbuntu; then
            :
        elif runningArch; then
            aurinstall "https://aur.archlinux.org/packages/ch/chruby/chruby.tar.gz"
        elif runningMint; then
            :
        fi
        echo "" >> ~/.bashrc
        echo "# Added by the canvas-lms setup script" >> ~/.bashrc
        echo "# These settings make chruby work" >> ~/.bashrc
        echo "# See https://github.com/postmodern/chruby" >> ~/.bashrc

        [ -f /usr/local/share/chruby/chruby.sh ] && echo ". /usr/local/share/chruby/chruby.sh" >> ~/.bashrc
        [ -f /usr/local/share/chruby/auto.sh ] && echo ". /usr/local/share/chruby/auto.sh" >> ~/.bashrc
        [ -f /usr/share/chruby/chruby.sh ] && echo ". /usr/share/chruby/chruby.sh" >> ~/.bashrc
        [ -f /usr/share/chruby/auto.sh ] && echo ". /usr/share/chruby/auto.sh" >> ~/.bashrc
        echo "PATH=$PATH:TODO" >> ~/.bashrc

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
    if ! hasGit; then
        if runningOSX; then
            echo # TODO
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
    cd "$canvasdir" 
    if [ -d canvas-lms ]; then 
        blue "You may already have a canvas checkout (the directory exists).\n"
        blue "Delete it and reclone? (Y/N): "
        read RESP
        if [[ $RESP =~ [Yy] ]]; then
            rm -rf canvas-lms
        else
            return 0
        fi
    fi

    git clone https://github.com/instructure/canvas-lms.git
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

installBundler ()
{
    if [ -n "$BUNDLE_VER" ]; then
        green "Installing the bundle gem version $BUNDLE_VER\n"
        gem install bundler -v "$BUNDLE_VER"
    else
        green "Installing the bundle gem newest version\n"
        gem install bundler
    fi

}

installGems ()
{
    green "Installing bundler gems with bundle install (but no mysql)\n"
    bundle install --without mysql
    if [ "$?" != "0" ]; then
        if [ -z "$already_attempted" ] && $(bundle install --without mysql 2>&1 | grep "version .* is required" >/dev/null); then
            already_attempted=y
            BUNDLE_VER="$(bundle install --without mysql 2>&1 | awk '{print $3}')"
            yes "Y" | gem uninstall bundler
            installBundler
            installGems
        fi
    fi
}

installRubyRI ()
{
    ruby-install --no-reinstall ruby 2.1.2
    cd .
    ruby --version | grep "2\.1\.2" >/dev/null
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

if chrubySupported; then
    blue "Do you want to use chruby and ruby-install (recommended)? (Y/N): "
    read CHRUBY
else
    CHRUBY=N
fi

blue "Do you want to generate ctags? (Y/N): "
read CTAGS

installDistroDependencies
installRuby || die "Error installing Ruby on your system.  Please install manually and try again"
installNodejs || die "Error installing Node.js on your system.  Please install manually and try again"
installBrew || die "Error installing Home Brew on your system.  Please install manually and try again"
if [[ $CHRUBY =~ [Yy] ]]; then installChruby || die "Error installing Chruby on your system.  Please install manually and try again"; fi
if [[ $CHRUBY =~ [Yy] ]]; then installRubyinstall || die "Error installing Chruby on your system.  Please install manually and try again"; fi
installPostgres || die "Error installing Postgres on your system.  Please install manually and try again"
installGit || die "Error installing Git on your system.  Please install manually and try again"
cloneCanvas || die "Error cloning Canvas.  Please check your network connection"
cd "$canvaslocation" || die "Could not move to the newly cloned directory"
if [[ $CHRUBY =~ [Yy] ]]; then writeChrubyFile || die "Error writing Chruby file to your repo.  Please install create the file manually and try again"; fi
if [[ $CHRUBY =~ [Yy] ]]; then installRubyRI || die "Error installing ruby with ruby-install.  Please try manually and run this script again"; fi
installBundler || die "Error install bundle.  Please install bundle manually and try again"
installGems || die "Error installing required gems.  Please run 'bundle install' manually and try again"
buildCanvasAssets || die "Error building Canvas assets.  Please build manually and try again"
createDatabaseConfigFile || die "Error creating the database config files"
createDatabases || die "Error building the databases.  Please ensure PostgreSQL is installed and running and try again"
if [[ $CTAGS =~ [Yy] ]]; then generateCtags || die "Error generating ctags"; fi
