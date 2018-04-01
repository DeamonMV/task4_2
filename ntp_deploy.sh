#!/bin/bash
NTP_C="/etc/ntp.conf"
NTP_C_B="/etc/ntp.conf.bak"
NTP_C_MD="/tmp/ntp.configured.md5"
if [ "$(dpkg -l |grep  -wcE "ntp")"  -eq "0" ]; then
   FIRST="1"
else
   FIRST="0"
fi

if [ "$FIRST" -eq "1" ]; then
   apt-get update
   apt-get install -y ntp
   sed -i 's/\(^pool.*ntp.*$\)/#\1/g' /etc/ntp.conf
   echo "pool ua.pool.ntp.org" >> /etc/ntp.conf
   cp $NTP_C $NTP_C_B
   md5sum $NTP_C > $NTP_C_MD
fi

CRON=$(crontab -l 2>/dev/null | grep -c "ntp_verify.sh")
PWD=$(pwd)
if [ "$CRON" -eq "0" ]; then
	(crontab -l 2>/dev/null; echo "* * * * * $PWD/ntp_verify.sh") | crontab - 
fi

#if [  "$FIRST" -eq "0" ]; then
#   if [ "$(cat ${NTP_C_MD})" == "" ] || [ ! -f $NTP_C_MD ]; then
#      rm $NTP_C
#      apt-get -o Dpkg::Options::="--force-confmiss" install -y --reinstall ntp
#      sed -i 's/\(^pool.*ntp.*$\)/#\1/g' /etc/ntp.conf
#      echo "pool ua.pool.ntp.org" >> /etc/ntp.conf
#      md5sum $NTP_C > $NTP_C_MD
#      cp $NTP_C $NTP_C_B
#   elif [ "$(md5sum $NTP_C_B | cut -d' ' -f1 | sed -e 's/\s\+//g')" != "$(cat $NTP_C_MD | cut -d' ' -f1 | sed -e 's/\s\+//g')" ]; then
#      rm $NTP_C
#      apt-get -o Dpkg::Options::="--force-confmiss" install -y --reinstall ntp
#      sed -i 's/\(^pool.*ntp.*$\)/#\1/g'
#      echo "pool ua.pool.ntp.org" >> ntp.conf
#      md5sum /etc/ntp.conf > /tmp/ntp.configured.md5
#      cp $NTP_C $NTP_C_B
#   fi
#fi
#
systemctl restart ntp
