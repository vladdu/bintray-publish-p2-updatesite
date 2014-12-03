#!/bin/bash
#Sample Usage: pushToBintray.sh username apikey owner repo package version simple|latest
API=https://api.bintray.com
BINTRAY_CREDENTIAL=$1
BINTRAY_OWNER=$2
BINTRAY_REPO=$3
PCK_NAME=$4
PCK_VERSION=$5
SITE_FORMAT=${6:-simple}

function main() {
deploy_updatesite
}

function deploy_updatesite() {
echo "${BINTRAY_CREDENTIAL}"
echo "${BINTRAY_OWNER}"
echo "${BINTRAY_REPO}"
echo "${PCK_NAME}"
echo "${PCK_VERSION}"

FILES=./*
PLUGINDIR=./plugins/*
FEATUREDIR=./features/*

if [ $SITE_FORMAT -eq "simple" ]; then
  # create a separate directory for each version
  OUTPATH="$PCK_VERSION"
else 
  if [ $SITE_FORMAT -eq "latest" ]; then
    # store all files at the root of the repository
    OUTPATH=""
  else
    echo "Site format must be 'simple' or 'latest'"
    exit 1
  fi
fi


for f in $FILES;
do
if [ ! -d $f ]; then
  echo "Processing $f file..."
  curl -X PUT -T $f -u ${BINTRAY_CREDENTIAL} \
    ${API}/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$OUTPATH/$f;publish=1
  echo ""
fi
done

echo "Processing features dir $FEATUREDIR file..."
for f in $FEATUREDIR;
do
  echo "Processing feature: $f file..."
  curl -X PUT -T $f -u ${BINTRAY_CREDENTIAL} \
    ${API}/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$OUTPATH/$f;publish=1
  echo ""
done

echo "Processing plugin dir $PLUGINDIR file..."

for f in $PLUGINDIR;
do
  echo "Processing plugin: $OUTPATH/$f file..."
  curl -X PUT -T $f -u ${BINTRAY_CREDENTIAL} \
    ${API}/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$OUTPATH/$f;publish=1
  echo ""
done

echo "Publishing the new version"
curl -X POST -u ${BINTRAY_CREDENTIAL} \
  ${API}/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/publish \
  -d "{ \"discard\": \"false\" }"

}


main "$@"
