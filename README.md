#README#

##manback: A simple backup script written in bash.##

manback is a utility that will make recursive backups of a directory for recovery purposes.
The utility assumes you have a continuously connected hard drive to back up to. This can be attached via usb or internal connection as long as a UUID is supplied and is static. 

The script will make a set of directories of the backup directory and makes hard links to the files that have changed since the last backup. This method results in a directory that you can use regular linux commands as search utilities. 

There are a few things to set up before you run the script. 

1) _Obtaining the code_
Save the git repository in root's home directory. You can either clone the git repository or download the source from _https://github.com/patrickmalsom/manback_

2) _Configuring the backup device_
You need to have another hard drive or other backup medium attached to the system. Add an entry to /etc/fstab for the backup device. The fstab entry should mount the backup device as read only on bootup  and use a UUID (ls -l /dev/disk/by-uuid) to identify the device. Here is an example:
UUID=2c8c806b-b73f-418d-888c-b6d342064890   /root/backup   ext4   defaults,ro   1   1

2) _Edit the config file_
manback.conf should be edited with the values you find appropriate. 

3) _Edit cron to automate_
Backups should happen without you requesting them, so use cron. A simple cron entry that backs up 4 times a day every day is:
```0 0,6,12,18 * * * /bin/bash /root/manback/manback > /dev/null```
If you wish to request a backup at a different time than the cron job you can simply run the script from the command line
```sudo /bin/bash /root/manback/manback```

###Exclude file###

An example exclude file. The default location is /root/manback/manback.exclude
```bash
#rsync script exclude file
**/.gvfs


#do not backup the following directories and all subdirectories
/home/patrick/.gvfs
/home/patrick/.local/share/Trash

# do not backup files with these extensions
**/*.temp
**/*.dat
```
