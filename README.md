# gost-stunnel-CSP

ГОСТ туннель для подключения к госсервисам:
- ГИС ЖКХ
- Росфинмониторинг
- и т.д.

За основу взят проект:
https://github.com/0xssanechka/GOST-stunnel/tree/main

Работа с Крипто Про и некоторые моменты отсюда:
https://pushorigin.ru/cryptopro/cryptcp?ysclid=m9b7b92aqt193934357


## Структура репозитория
```
.
│   Dockerfile
│
├───bin
│       entrypoint.sh
│       stunnel-socat.sh
│
├───data
│       999996.000
│       CA.crt
│       certificate.cer
│       stunnel.conf
│
└───cprocsp
        linux-amd64_deb.tgz
```
### Папка data 
Должна содержать сведения о сертификате клиента и пробрасывается в систему.
Сертификат в образ не компилируется.
Содержимое папки:
- CA.crt - сертификат УЦ
- 999996.000 - приватный ключ с флэшки
- certificate.cer - личный сертификат без ключа
- linux-amd64_deb.tgz - КриптоПро CSP для Linux x64 DEB

Заменить на свои:
- содержимое папки 999996.000
- certificate.cer
  (в формате PEM)


## Сборка
### Для локального запуска
docker build . -t proxy-gost

### Для отправки на dockerhub учетка admin@crkc.ru:
[] Сборка:
docker build -t xxx/xxx:proxy-gost-latest .
[] Отправить в репозиторий:
docker push xxx/xxx:proxy-gost-latest


## Запуск
### Общий синтаксис
docker run -p 8080:8080 -e STUNNEL_HOST=<TARGET-HOST>:443 -e STUNNEL_HTTP_PROXY=<HTTP-PROXY-HOST> -e STUNNEL_HTTP_PROXY_PORT=<PORT>-e STUNNEL_HTTP_PROXY_CREDENTIALS=<LOGIN:PASS> proxy-gost

### Росфинмониторинг
docker run -p 8080:8080 -e STUNNEL_HOST=portal.fedsfm.ru:8081 xxx/xxx:proxy-gost-latest
docker run -p 8080:8080 -e STUNNEL_HOST=portal.fedsfm.ru:8081 -v data:/etc/stunnel --name asmp-proxy-gost --rm xxx/xxx:proxy-gost-latest

[] Проверка:
curl http://localhost:8080/Services/fedsfm-service
