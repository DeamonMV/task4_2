#!/bin/bash
NTP_C="/etc/ntp.conf"
NTP_C_B="/etc/ntp.conf.bak"
NTP_C_MD="/tmp/ntp.configured.md5"

# def does ntp work
if [ "$(ps aux | grep "ntpd" | grep -v "grep" | sed -e 's/\s\+/ /g' | cut -d' ' -f 2)" == "" ]; then
    echo "NOTICE: ntp is not running"
    systemctl restart ntp
    ID=$(ps aux | grep "ntpd" | grep -v "grep" | sed -e 's/\s\+/ /g' | cut -d' ' -f 2)
elif [ "$(ntpq -pn 2> /dev/null | grep -c "=======")" -eq "0" ];  then
    echo "NOTICE: ntp is not running"
    systemctl restart ntp
    ID=$(ps aux | grep "ntpd" | grep -v "grep" | sed -e 's/\s\+/ /g' | cut -d' ' -f 2)
elif [ -f /var/run/ntpd.pid ] && [ ! "$(ntpq -np | grep -c "=======")" ]; then
    echo "3 NOTICE: ntp is not running"
    systemctl restart ntp
    ID=$(cat /var/run/ntpd.pid)
elif [ "$(systemctl is-active --quiet service)" ]; then
    echo "NOTICE: ntp is not running"
    systemctl restart ntp
fi

if [ "$(cat ${NTP_C_MD})" == "" ] || [ ! -f $NTP_C_MD ]; then
   echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"
   diff -u $NTP_C $NTP_C_B | sed -e '/drift/d' | sed -e '/^\s*$/d'
   if [ "$(md5sum $NTP_C_B | cut -d' ' -f1 | sed -e 's/\s\+//g')" != "$(cat $NTP_C_MD | cut -d' ' -f1 | sed -e 's/\s\+//g')" ]; then
      rm $NTP_C
      apt-get -o Dpkg::Options::="--force-confmiss" install -y --reinstall ntp 1>&2 > /dev/null
      sed -i 's/\(^pool.*ntp.*$\)/#\1/g' $NTP_C
      echo "pool ua.pool.ntp.org" >> $NTP_C
      md5sum $NTP_C > $NTP_C_MD
      cp $NTP_C $NTP_C_B
      systemctl restart ntp
   else
      cp $NTP_C_B $NTP_C
     systemctl restart ntp
   fi

elif [ "$(md5sum $NTP_C | cut -d' ' -f1 | sed -e 's/\s\+//g')" != "$(cat $NTP_C_MD | cut -d' ' -f1 | sed -e 's/\s\+//g')" ]; then

   echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"
   diff -u $NTP_C $NTP_C_B | sed -e '/drift/d' | sed -e '/^\s*$/d'
   if [ "$(md5sum $NTP_C_B | cut -d' ' -f1 | sed -e 's/\s\+//g')" != "$(cat $NTP_C_MD | cut -d' ' -f1 | sed -e 's/\s\+//g')" ]; then
      rm $NTP_C
      apt-get -o Dpkg::Options::="--force-confmiss" install -y --reinstall ntp 1>&2 > /dev/null
      sed -i 's/\(^pool.*ntp.*$\)/#\1/g' $NTP_C
      echo "pool ua.pool.ntp.org" >> $NTP_C
      md5sum $NTP_C > $NTP_C_MD
      cp $NTP_C $NTP_C_B
      systemctl restart ntp
   else
      cp $NTP_C_B $NTP_C
     systemctl restart ntp
   fi
elif [ ! -f $NTP_C_B ] && [ "$(md5sum $NTP_C | cut -d' ' -f1 | sed -e 's/\s\+//g')" == "$(cat $NTP_C_MD | cut -d' ' -f1 | sed -e 's/\s\+//g')" ]; then
      cp $NTP_C $NTP_C_B
fi

