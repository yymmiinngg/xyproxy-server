
#!/bin/bash

echo "Check build environment."
zip -H > /dev/null
if [ $? -ne 0 ]; then
    echo "Command 'zip' not found, please install it first."
    exit 1
fi

git --help > /dev/null
if [ $? -ne 0 ]; then
    echo "Command 'git' not found, please install it first."
    exit 1
fi

echo "Check args."
version=$1
if [ -z "$version" ]; then
    echo "Please input arg[1] version."
    exit 1
fi

includeConfig=$2
if [ -z "$includeConfig" ]; then
    echo "Please input arg[2] include config, like \"all\", \"test\" or \"prod\"."
    exit 1
fi

cmdfile=$(readlink -f $0)
buildPath=$(dirname $cmdfile)
projectPath=$(dirname $buildPath)
tempdir="$buildPath/temp"
distdir="$buildPath/dist"

if [ "$includeConfig" != "all" ] && [ ! -d "$projectPath/config/$includeConfig" ]; then
    echo "Include config path not exists."
    exit 1
fi

echo "Make dir for building."
mkdir -p $tempdir
mkdir -p $distdir

function clearTempFiels () {
    echo "Clear temp files."
    cd $buildPath
    rm -rf $tempdir
    if [ -n "$1" ]; then
        echo $1
    fi
}

echo "Let's building..."
# time=$(date "+%Y%m%d_%H%M%S")
includeConfigFilename=`echo $includeConfig | sed s/\\\\//./g`
packageName="xyserver-install-package-$includeConfigFilename.$version.zip"
xysZipName="$version.zip"

# cp $buildPath/install-xyserver.sh $projectPath
echo "Make zip app package..."
cd "$projectPath"

zip -r "$tempdir/$xysZipName" ./* -x ".*" -x "build/*" -x "config/*"

if [ "$includeConfig" == "all" ]; then
    zip -r "$tempdir/$xysZipName" config/* -x ".*"
else
    includeConfigPath="config/$includeConfig"
    zip -r "$tempdir/$xysZipName" $includeConfigPath/* -x ".*"
    while [ "$includeConfigPath" != "config" ]; do
        includeConfigPath=$(dirname "$includeConfigPath")
        zip -r "$tempdir/$xysZipName" $includeConfigPath/*.json
    done
fi


echo "Make zip install package..."
cd "$tempdir"
zip "$tempdir/$packageName" "$xysZipName"
if [ $? -ne 0 ]; then
    clearTempFiels "Build fail."
    exit 1
fi
cd "$buildPath"
zip "$tempdir/$packageName" "install-xyserver.sh"
if [ $? -ne 0 ]; then
    clearTempFiels "Build fail."
    exit 1
fi

mv -f "$tempdir/$packageName" "$distdir/$packageName"

echo "Dist: $distdir/$packageName"

clearTempFiels "Build sucess."