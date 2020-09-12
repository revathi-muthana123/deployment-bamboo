#!/bin/bash -e

if [ "$1" == "-h" ] ; then
    echo "Usage: `basename $0` [branchname]"
    echo ""
    echo "branchname    the name of the branch to use in deployment-bamboo repo - defaults to 'develop' if not given"
    exit 0
fi

# let's be verbose on what we are doing (do not set it earlier or the help message will look ugly)
set -x

# cleanup possible last run (failures) silently
rm -f bambooForCodeDeploy.zip
rm -rf source

# checkout package content from a given branch to have a clean package
BRANCH=${1:-develop}
git clone ssh://git@scr.bsh-sdd.com:7999/sdds/deployment-bamboo.git source
cd source
git checkout $BRANCH

# install roles we depend on
cd ansible
ansible-galaxy install -r requirements.yml
cd ..

# copy vault password
cp ../../ansible/vault_password_file ansible

# zip the necessary stuff (by ignoring the unneccessary)
zip -r ../bambooForCodeDeploy.zip ./* -x .gitignore .git/\* /target/\*
cd ..

# cleanup
rm -rf source
