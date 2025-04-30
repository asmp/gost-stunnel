#!/bin/bash
# скрипт инициализации

# ---------------------------------
# настройка csp

echo "Configuring CryptoPro CSP..."
certmgr -install -file /etc/stunnel/CA.crt -store mCA -silent
cp -R /etc/stunnel/999996.000 /var/opt/cprocsp/keys/root/
chmod 600 /var/opt/cprocsp/keys/root/999996.000/*
echo "Certificate was imported."
echo

# определение контейнера-хранилища закрытых ключей
containerName=$(csptest -keys -enum -verifyc -fqcn -un | grep 'HDIMAGE' | awk -F'|' '{print $2}' | head -1)
if [[ -z "$containerName" ]]; then
    echo "Keys container not found"
    exit 1
fi

# импорт сертификата с закрытым ключом
certmgr -inst -file /etc/stunnel/certificate.cer -cont "${containerName}" -silent || exit 1

# установка сертификата клиента
certmgr -inst -cont "${containerName}" -silent || exit 1

# экспорт сертификата для stunnel
exportResult=$(certmgr -export -dest /etc/stunnel/client.crt -container "${containerName}")
if [[ ! -f "/etc/stunnel/client.crt" ]]; then
    echo "Error on export client certificate"
    echo "$result"
    exit 1
fi

echo "CSP configured."
echo

# ---------------------------------
# запуск socat
echo "Starting socat..."
nohup bash /stunnel-socat.sh </dev/null >&1 2>&1 &
# ---------------------------------
# запуск stunnel
echo "Configuring stunnel..."
sed -i "s/^debug=.*$/debug=$STUNNEL_DEBUG_LEVEL/g" /etc/stunnel/stunnel.conf

echo "Starting stunnel"
exec "$@"