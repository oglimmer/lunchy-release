#!/bin/sh

cd ../repos/lunchy/

LATEST_MINOR_VERSION=$(git describe --abbrev=0 --tags | grep -o "[0-9]*$")
NEW_MINOR_VERSION=$((LATEST_MINOR_VERSION + 1))
NEW_MINOR_VERSION_PLUS_ONE=$((NEW_MINOR_VERSION + 1))

TAG=lunchy-0.$NEW_MINOR_VERSION
RELEASE=0.$NEW_MINOR_VERSION
DEV=0.$NEW_MINOR_VERSION_PLUS_ONE-SNAPSHOT

echo "********************************************************************"
echo "Create new release with:"
echo "TAG=$TAG"
echo "RELEASE=$RELEASE"
echo "DEV=$DEV"

read -p "Press [Enter] key to start release..."

mvn --batch-mode -Dtag=$TAG -DreleaseVersion=$RELEASE -DdevelopmentVersion=$DEV release:prepare

rm -f pom.xml.releaseBackup
rm -f release.properties

read -p "Press [Enter] key to start push to remote..."

git push

cd ../../server/ansible
sed -i -e 's/lunchy_version.*/lunchy_version: lunchy-'$RELEASE'/g' roles/lunchy/vars/main.yml

echo "This is the version in the UI:"
grep lunchy_version roles/lunchy/vars/main.yml

read -p "Press [Enter] key to start push to deploy to server..."

./deploy.sh -d production lunchy


