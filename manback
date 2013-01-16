#!/bin/bash
# ----------------------------------------------------------------------
# Rotating backup utility
# ----------------------------------------------------------------------

# configuration file. 
source manback.conf

# ------------- the script itself --------------------------------------
# Index for the backup starts at 100

# Check for root privilages. Exit if false.
if (( `/usr/bin/id -u` != 0 )) ; then { /bin/echo "Sorry, must be root.  Exiting..." ; exit ; } fi

# Remount the RO mount point as RW; else abort
/bin/mount -o remount,rw -U $MOUNT_DEVICE $SNAPSHOT_MOUNT ;
if (( $? )) ; then
{
  /bin/echo "snapshot: could not remount $SNAPSHOT_MOUNT readwrite. Exiting...";
  exit ;
}
fi ;

# Create the backup directory if it does not exist
if [ ! -d "$SNAPSHOT_MOUNT$BACKUP_DIR" ]; then
  /bin/mkdir -p $SNAPSHOT_MOUNT$BACKUP_DIR
  if [ ! -d "$SNAPSHOT_MOUNT$BACKUP_DIR" ]; then
    /bin/echo "could not create $SNAPSHOT_MOUNT$BACKUP_DIR. Exiting...";
    exit;
  fi;
fi

# Delete the maximum valued snapshot, if it exists:
if [ -d $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.$((100+$TOTALSNAPS)) ] ; then
/bin/rm -rf $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.$((100+$TOTALSNAPS)) ;
fi ;

# Shift the middle snapshots back by one, if they exist
for (( i = $((100+$TOTALSNAPS)) , j = $((99+$TOTALSNAPS)); i > 101; i-- ,j--))
do
  if [ -d $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.$j ] ; then
  {
    /bin/mv $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.$j $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.$i ;
  }
  fi ;
done

# Make a hard-link-only (except for dirs) copy of latest snapshot
if [ -d $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100 ] ; then
  /bin/cp -al $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100  $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.101 ;
fi;

if [ ! -d $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100 ] ; then
  /bin/mkdir $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100 ;
fi;

# Rsync from the system into the latest snapshot 
/usr/bin/rsync -va --delete --delete-excluded --exclude-from="$EXCLUDES" $BACKUP_DIR/ $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100

# Update the mtime of $SNAPSHOT_NAME.100 to reflect the snapshot time
/bin/touch $SNAPSHOT_MOUNT$BACKUP_DIR/$SNAPSHOT_NAME.100 ;

# Remount the RW snapshot mountpoint as readonly
/bin/mount -o remount,ro -U $MOUNT_DEVICE $SNAPSHOT_MOUNT ;
if (( $? )) ; then
{
  /bin/echo "snapshot: could not remount $SNAPSHOT_MOUNT readonly" ;
  exit ;
} fi ;
