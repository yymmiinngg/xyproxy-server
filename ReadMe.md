# XYSERVER

Xyserver is a proxy server based on v2ray.

## build

Args

* arg[1]: version tag
* arg[2]: include config

```
$> cd build
$> sh build.sh release-1.0.1 prod
Check build environment.
Check args.
Make dir for building.
Let's building...
Make zip app package...
  adding: ReadMe.md (deflated 78%)
  ......
Make zip install package...
  adding: release-1.0.1.zip (stored 0%)
  adding: install-xyserver.sh (deflated 67%)
Dist: /mnt/e/code/mss/mss-proxy-server/build/dist/xyserver-install-package-prod.release-1.0.1.zip
Clear temp files.
Build sucess.
```

Has successed if you can see, install package is "xyserver-install-package-$inconfig.$version.zip".

```
Dist: /mnt/e/code/mss/mss-proxy-server/build/dist/xyserver-install-package-$inconfig.$version.zip
......
Clear temp files.
```

## install

1. Get the install package like "xyserver-install-package-$inconfig.$version.zip", unzip it.

```
-rwxrwxrwx. 1 root root     4365 Apr 27 14:18 install-xyserver.sh
-rwxrwxrwx. 1 root root 12198330 May  8 15:50 release-0.1.0.zip
-rw-r--r--. 1 root root 12200135 May  8 15:50 xyserver-install-package-prod.release-0.1.0.zip
```

2. Run install script.

```
$> sh install-xyserver.sh release-0.1.0.zip 
Use default home '/opt/xyserver'
Use default user 'xyserver'
Use default logs '/opt/xyserver/logs'
useradd: user 'xyserver' already exists
Removing password for user xyserver.
passwd: Success
Make dir...
Unzip files...
Archive:  release-0.1.0.zip
 extracting: /opt/xyserver/release-0.1.0/ReadMe.md  
 ......
Fill variables into file /opt/xyserver/release-0.1.0/environment.
Fill variables into file /opt/xyserver/release-0.1.0/script/xyserver.service.
Proxy-server installed into /opt/xyserver.
Switch version to release-0.1.0
Reload service config.
Removed symlink /etc/systemd/system/multi-user.target.wants/xyserver.service.
Removed symlink /etc/systemd/system/xyserver.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/xyserver.service to /opt/xyserver/current/script/xyserver.service.
Created symlink from /etc/systemd/system/xyserver.service to /opt/xyserver/current/script/xyserver.service.
Switch verison 'release-0.1.0' -> 'release-0.1.0' done.
Install success.
```

If you want to setting some args, you can see help.

```
$> sh install-xyserver.sh --help
Usage: install-xyserver.sh <ZipFile> [Options]
    ZipFile             the xyserver zip file.
Options:
    --home=HOME_DIR     the xyserver home dir will be install to, default is '/opt/xyserver'
    --user=USER         the xyserver user, default is 'xyserver'
    --logs=LOGS_DIR     the xyserver logs dir, default is '$HOME_DIR/logs'
    -c                  cover the exists files, delete the version home dir before install
    -h, --help          display this help and exit
```

3. Use the config path

```
$> xyconfig -s prod
Make config use 'prod' and update config file /opt/xyserver/release-1.0.2/config.runtime
```

4. Start server & show status

```
$> systemctl start xyserver
$> systemctl status xyserver
```

If service start fail, you can instead of cmd.

```
$> xyserver start
$> xyserver status
```

## Change version

1. current version

```
$> xyversion
release-1.0.1
```

2. list all installed version

```
$> xyversion -l
current
release-0.1.0
release-1.0.1
```

3. change version

```
$> xyserver release-0.1.0
Reload service config.
Removed symlink /etc/systemd/system/multi-user.target.wants/xyserver.service.
Removed symlink /etc/systemd/system/xyserver.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/xyserver.service to /opt/xyserver/current/script/xyserver.service.
Created symlink from /etc/systemd/system/xyserver.service to /opt/xyserver/current/script/xyserver.service.
Switch verison 'release-1.0.1' -> 'release-0.1.0' done.
```
