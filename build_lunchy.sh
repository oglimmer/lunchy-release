#!/bin/sh

cd ../repos/lunchy-build/

git fetch && git pull

LAST_MESSAGE=$(git log --format=%B -n 1)
$(echo $LAST_MESSAGE | grep -q "\[maven-release-plugin\] prepare for next development iteration")
LAST_MESSAGE_C1=$?
$(echo $LAST_MESSAGE | grep -q "\[maven-release-plugin\] prepare release lunchy-")
LAST_MESSAGE_C2=$?

if [ $LAST_MESSAGE_C1 -ne 0 -o $LAST_MESSAGE_C2 -ne 0 ]; then
	echo "No commits since last tag. No build needed."
	exit 1
fi

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

if [ $? -ne 0 ]; then
	exit 1
fi

rm -f pom.xml.releaseBackup
rm -f release.properties

git push

cd ../../server/ansible
sed -i -e 's/lunchy_version.*/lunchy_version: lunchy-'$RELEASE'/g' roles/lunchy/vars/main.yml

echo "This is the version in the UI:"
grep lunchy_version roles/lunchy/vars/main.yml

./deploy.sh -d production lunchy
