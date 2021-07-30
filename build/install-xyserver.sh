#!/bin/bash

cmd=$(basename "$0")
cmdfile=$(readlink -f "$0")
cmdpath=$(dirname "$cmdfile")

# check user
if [ `whoami` != "root" ];then  
    echo "Not root user, please switch to root user!"  
    exit 1
fi

# check unzip command has installed
unzip -hh > /dev/null
if [ $? -ne 0 ]; then
    echo "Command 'unzip' not found, please install it first."
    exit 1
fi

# print help and exit
function help_exit(){
    if [ -n "$1" ]; then
        echo $1
    fi
    echo "Usage: $cmd <ZipFile> [Options]"
    echo "    ZipFile             the xyserver zip file."
    echo "Options:"
    echo "    --home=HOME_DIR     the xyserver home dir will be install to, default is '/opt/xyserver'"
    echo "    --user=USER         the xyserver user, default is 'xyserver'"
    echo "    --logs=LOGS_DIR     the xyserver logs dir, default is '\$HOME_DIR/logs'" 
    echo "    -c                  cover the exists files, delete the version home dir before install" 
    echo "    -h, --help          display this help and exit" 
    exit 1
}

# args
args=("$@")
params=()

# vars
xyserverZip=""
home=""
user=""
logs=""
cover=""

# args to vars
for((i=0;i<${#args[@]};i++));
do
    param="${args[$i]}"
    if [ -z "$(echo $param | grep '=')" ]; then
        if [ -z "$(echo $param | egrep -o '^-')" ]; then
            params[${#params[@]}]=$param
        else
            if [ "$param" == "-c" ]; then
                cover="yes"
            elif [ "$param" == "-h" ] || [ "$param" == "--help" ] ; then
                help_exit
            else
                help_exit "Unknow arg: '$param'"
            fi
        fi
    else
        key="${param%=*}"
        value="${param#*=}"
        if [ "$key" == "--home" ]; then
            home="$value"
        elif [ "$key" == "--user" ]; then
            user="$value"
        elif [ "$key" == "--logs" ]; then
            logs="$value"
        else
            help_exit "Unknow arg: '$key'"
        fi
    fi
done

# params check
xyserverZip="${params[0]}"
if [ -z "$xyserverZip" ]; then
    help_exit "Missing arg ZipFile."
fi
if [ ! -f "$xyserverZip" ]; then
    help_exit "ZipFile '$xyserverZip' not a good file!"  
fi

# default value for params
if [ -z "$home" ]; then
    home="/opt/xyserver"
    echo Use default home "'$home'"
fi
if [ -z "$user" ]; then
    user="xyserver"
    echo Use default user "'$user'"
fi
if [ -z "$logs" ]; then
    logs="$home/logs"
    echo Use default logs "'$logs'"
fi

# get the version from filename
version=$(echo $xyserverZip | sed s/\.zip//g)
versionHome="$home/$version"

# add user
useradd -M "$user"
passwd -d "$user"

# cover the dir
if [ -n "$cover" ] && [ -d "$versionHome"]; then
    echo Remove the exists version home "'$versionHome'".
    rm -fr "$versionHome"
fi
# make dir
echo Make dir...
mkdir -p "$home"
mkdir -p "$versionHome"
mkdir -p "$logs"

# flex file
echo Unzip files...
unzip -o -d "$versionHome" "$xyserverZip"
if [ $? -ne 0 ]; then
    echo "Install broked."
    exit 1
fi

function toSedStr(){
    echo "$1" | sed s/"\\/"/"\\\\\/"/g
}

# some default value
versionHome="$home/$version"
pidfile="$home/pid"
# chg to sed str
userStr=`toSedStr "$user"`
homeStr=`toSedStr "$home"`
versionStr=`toSedStr "$version"`
logsStr=`toSedStr "$logs"`
versionHomeStr=`toSedStr "$versionHome"`
pidfileStr=`toSedStr "$pidfile"`

for filename in "$versionHome/environment" "$versionHome/script/xyserver.service"
do
    echo Fill variables into file "$filename".
    sed -i s/\$XYSERVER_USER/"$userStr"/g "$filename"
    sed -i s/\$XYSERVER_HOME/"$homeStr"/g "$filename"
    sed -i s/\$XYSERVER_VERSION/"$versionStr"/g "$filename"
    sed -i s/\$XYSERVER_LOGS/"$logsStr"/g "$filename"
    sed -i s/\$XYSVERSION_HOME/"$versionHomeStr"/g "$filename"
    sed -i s/\$XYSERVER_PID/"$pidfileStr"/g "$filename"
done

echo Proxy-server installed into "$home".

chown "$user" "$home"
chown "$user" "$versionHome" -R
chown "$user" "$logs" -R
chmod 775 `find "$versionHome" -type d`
chmod 664 `find "$versionHome" -type f`
chmod +x "$versionHome/xyconfig"
chmod +x "$versionHome/xyserver"
chmod +x "$versionHome/xyversion"
chmod +x "$versionHome/v2ray/v2ray"
chmod +x "$versionHome/v2ray/v2ray.sig"
chmod +x "$versionHome/v2ray/v2ctl"
chmod +x "$versionHome/v2ray/v2ctl.sig"

# switch to new version
echo Switch version to $version
$versionHome/xyversion $version

echo Install success.