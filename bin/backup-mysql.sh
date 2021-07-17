#!/bin/bash
# Script to backup MySQL databases
#
# VERSION: 20120501-webdbdev
#
# Changelog:
# 20190712 - (rwahyudi) :
# - Use .my.cnf
# - Send email notification when fail
# - parallel gzip on the fly
# - fit it mariadb 10+

BACKUPDIR="/home/.backup/mysql"
DATE=$(date '+%d-%m-%Y_%H%M%S')
MAILTO=rwahyudi@gmail.com
ERROR_LOG=/tmp/dbdump_error.log
let ERR=0
ERR_MSG="`date` : [ERROR] - MySQL backup failed to run on `hostname -s` \r \n"



if [ ! -e  /root/.my.cnf ]
then
        echo -e "$ERR_MSG \r \n Error Code : No .my.cnf file" | mail -s "[ERROR] - MySQL backup failed to run on `hostname -s`" $MAILTO
        exit
fi

mkdir -p $BACKUPDIR

# Remove old files
find $BACKUPDIR/ -type f -mtime +2 -exec rm -f {} \;

for DATABASE in `echo "show databases;" | mysql -B --skip-column-names |grep -v information_schema | grep -v performance_schema `
do
        cat /dev/null > $ERROR_LOG
    mysqldump -E --opt --events --ignore-table=mysql.event $DATABASE --log-error=$ERROR_LOG | pigz -c  > $BACKUPDIR/$DATABASE-$DATE.sql.gz
        if [ -s $ERROR_LOG ]
        then
                let ERR++
                LOG_CONTENT=`cat $ERROR_LOG`
                ERR_MSG="$ERR_MSG
                ------------------------------------------------------------------------------------- \r \n
                DATABASE : $DATABASE \r \n
                $LOG_CONTENT \r \n

                "
        fi
done

if [ $ERR -gt 0 ]
then
        echo -e $ERR_MSG | mail -s "[ERROR] - MySQL backup failed to run on `hostname -s`" $MAILTO
fi

