#!/bin/bash
NTP_C="/etc/ntp.conf"
NTP_C_B="/etc/ntp.conf.bak"
NTP_C_MD="/tmp/ntp.configured.md5"

apt-get -qq update -y
apt-get install  ntp -y -qq 
sed -i 's/\(^pool.*ntp.*$\)/#\1/g' /etc/ntp.conf
echo "pool ua.pool.ntp.org" >> /etc/ntp.conf

cp $NTP_C $NTP_C_B
md5sum $NTP_C > $NTP_C_MD

CRON=$(crontab -l 2>/dev/null | grep -c "ntp_verify.sh")
PWD=$(pwd)
if [ "$CRON" -eq "0" ]; then
	(crontab -l 2>/dev/null; echo "* * * * * $PWD/ntp_verify.sh") | crontab - 
fi

systemctl restart ntp
