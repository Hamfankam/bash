#!/bin/bash
server="${1}"
login=root
pathkey=/home/utilizator/dir_key/ha_priv_key.pem
pathcert=/ssl/
fullchaincrt=fullchain.pem
certprivkey=privkey.pem
for var1 in fullchain privkey
	do
	if [ "$var1" == "fullchain" ]; then
		var2=$fullchaincrt
	else
		if [ "$var1" == "privkey" ]; then
			var2=$certprivkey
		else
			exit 1
		fi
	fi
	# Проверка на пустую переменную var2, если да, прерываем итерацию
	if [ -z "${var2}" ]; then
		continue
	fi
	var_tmp1=$(find /etc/letsencrypt/archive/cascading.ru-0001/ -mtime -45 -printf '%f\n' | grep ^$var1*)
	if [ -z "${var_tmp1}" ]; then
		continue
	fi
	sudo ssh -i $pathkey $login@$server "chmod 644 $pathcert$var2"
	sudo ssh -i $pathkey $login@$server "mv $pathcert$var2 $pathcert$var2.bak"
	var_tmp2=$(find /etc/letsencrypt/archive/cascading.ru-0001/ -mtime -45 -print | grep /$var1*)
	if [ -z "${var_tmp2}" ]; then
		continue
	fi
	scp -i $pathkey $var_tmp2 $login@$server:$pathcert
	sudo ssh -i $pathkey $login@$server "mv $pathcert$var_tmp1 $pathcert$var2"
	sudo ssh -i $pathkey $login@$server "chmod 600 $pathcert$var2"
done
# Команда на перезагрузку сервера HA
sudo ssh -i $pathkey $login@$server "source /etc/profile.d/homeassistant.sh; ha host reboot"
exit 1
