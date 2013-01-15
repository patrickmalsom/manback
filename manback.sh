#!/bin/bash
# ----------------------------------------------------------------------
# Rotating backup utility
# ----------------------------------------------------------------------
unset PATH ;  # avoid accidental use of $PATH
# ------------- file names and locations -------------------------------
MOUNT_DEVICE=2c8c806b-b73f-418d-888c-b6d342064890 ; #UUID label to be safe
SNAPSHOT_MOUNT=/root/backup ; 
BACKUP_DIR=/home ;
SNAPSHOT_NAME=snap ;
EXCLUDES=/root/backup_exclude ;

# ------------- the script itself --------------------------------------
# Makes 56 total snapshots (4 per day for two weeks; index starts at 100)

# make sure this is running as root
if (( `/usr/bin/id -u` != 0 )) ; then { /bin/echo "Sorry, must be root.  Exiting..." ; exit ; } fi

# Remount the RO mount point as RW; else abort
/bin/mount -o remount,rw -U $MOUNT_DEVICE $SNAPSHOT_MOUNT ;
if (( $? )) ; then
{
  /bin/echo "snapshot: could not remount $SNAPSHOT_MOUNT readwrite";
  exit ;
}
fi ;

# Delete the maximum valued snapshot, if it exists:
if [ -d $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.156 ] ; then
/bin/rm -rf $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.156 ;
fi ;

# Shift the middle snapshots back by one, if they exist
for (( i = 156, j = 155; i > 101; i-- ,j--))
do
  if [ -d $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.$j ] ; then
  {
    /bin/mv $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.$j $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.$i ;
  }
  fi ;
done

# Make a hard-link-only (except for dirs) copy of latest snapshot
if [ -d $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.100 ] ; then
/bin/cp -al $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.100  $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.101 ;
fi;

# Rsync from the system into the latest snapshot 
/usr/bin/rsync -va --delete --delete-excluded --exclude-from="$EXCLUDES" $BACKUP_DIR/ $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.100 ;


# Update the mtime of $SNAPSHOT_NAME.0 to reflect the snapshot time
/bin/touch $SNAPSHOT_MOUNT/$BACKUP_DIR/$SNAPSHOT_NAME.100 ;

# Remount the RW snapshot mountpoint as readonly
/bin/mount -o remount,ro -U $MOUNT_DEVICE $SNAPSHOT_MOUNT ;
if (( $? )) ; then
{
  /bin/echo "snapshot: could not remount $SNAPSHOT_MOUNT readonly" ;
  exit ;
} fi ;
