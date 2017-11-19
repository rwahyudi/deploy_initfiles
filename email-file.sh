#!/bin/bash

# email files
MYFILETOSEND=$1
MYEMAILDEST=$2

function usage
{
        echo
        echo "Usage     : $0 <file> <email address>"
        echo "Example   : $0 /etc/fstab someone@example.com"
        exit 1
}

if [ ! -s "$MYFILETOSEND" ]
then
        echo
        echo " ERROR : Unable to open file / File does not exist / file is zero in size. "
        usage
fi

if [[ "$2" != *@* ]]
then
        echo
        echo " ERROR : Please specify valid email address "
        usage

fi


MYFILENAME=`/bin/basename $1`

 ( echo "Subject: Attachment: ${MYFILETOSEND}
Content-Type: multipart/mixed; boundary=boundary
--boundary
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=\"${MYFILENAME}\"
Content-Transfer-Encoding: base64
" ; openssl enc -base64 -in ${MYFILETOSEND} ; echo "--boundary--" ) | /usr/lib/sendmail ${MYEMAILDEST}

sleep 3
if [ `tail -n 100 /var/log/maillog | grep "$MYEMAILDEST" | egrep -i '(status=sent|stat=Sent)' | wc -l` -gt 0 ]
then
        echo "Mail has been sent"
else
        echo "Problem in sending out email"
fi
