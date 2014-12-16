#!/bin/bash

REPO_LOC="$HOME"
REPO_NAME="canvas-config-bk"

color_restore='\033[0m'
color_green='\033[0;32m'
color_yellow='\033[1;33m'

die ()
{
    echo "Error: $1"
    exit 1
}

[ -d config ] || die "Must be run in the root of your canvas checkout"

read -r -d '' VAR << __EOF__
${color_green}
Each time you run this script, your current canvas config files will be backed up to
a git repo located at ${REPO_LOC}/${REPO_NAME}.  If the repo doesn't exist yet, it
will be created.  Each running of this script will result in a new commit to the repo
containing any changes to your config files from the last time you ran it.
${color_restore}
__EOF__

echo -e "$VAR"

prevdir=$(pwd)
cd $REPO_LOC
mkdir -p $REPO_NAME

cd $REPO_NAME
$(git status >/dev/null 2>&1) || git init
cd $prevdir
cp -v config/*.yml "${REPO_LOC}/${REPO_NAME}/"
cd "${REPO_LOC}/${REPO_NAME}"
git add .
git ci -m "Add config files as of $(date)"

# If the user doesn't have a remote repo, tell them how to add one
if [[ "$(git remote -v | wc -l | xargs)" = "0" ]]; then
    read -r -d '' VAR << __EOF__
${color_green}
Your canvas config files are backup up into a git repo located at ${REPO_LOC}/${REPO_NAME}
${color_yellow}
You can push this to a remote private repo using: 
    git remote add origin <origin-url>
    pit push -u origin
${color_green}
For example, to back it up to bitbucket.org, it would be: 
    git remote add origin git@bitbucket.org:<username>/${REPO_NAME}.git
    git push -u origin
${color_restore}
__EOF__
    echo -e "$VAR"
else
    read -p "Do you want me to push the changes to your remote repository?" PUSH

    if [[ $PUSH =~ [Yy] ]]; then
        git push
    else
        echo "Ok, not pushing"
    fi
fi
