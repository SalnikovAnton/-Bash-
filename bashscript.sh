#!/bin/bash

#создаем файл блокировки
touch /var/tmp/script.lock

# если ранее файл отчета не создавался, создается новый. Момент последнего запуска скрипта для использования при следующих запусках записывается в первую строчку
test -f /bash-CRON/MESSAGE || echo "0000000000" > /bash-CRON/MESSAGE
let t=$(head -n1 /bash-CRON/MESSAGE)
echo $(date "+%s") > /bash-CRON/MESSAGE

# Создание письма
echo -en "\n\nРезультаты c access.log за период $(date -d@$t) - $(date -d@$(head -n1 /bash-CRON/MESSAGE))\n" >> /bash-CRON/MESSAGE

#Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo -en "\n\nТОП 10 IP адресов с наибольшим кол-вом запросов\n" >> /bash-CRON/MESSAGE
cat /bash-CRON/access.log | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | uniq -c | sort -nr | head -10 | head >> /bash-CRON/MESSAGE

#Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo -en "\n\nТОП 10 запрашиваемых URL\n" >> /bash-CRON/MESSAGE
cat /bash-CRON/access.log | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -10 | head >> /bash-CRON/MESSAGE

#Ошибки веб-сервера/приложения c момента последнего запуска
echo -en "\n\nОшибки веб-сервера/приложения\n" >> /bash-CRON/MESSAGE
cat /bash-CRON/access.log | grep ".*HTTP/1\.1\" [3,4,5].." | sort | uniq -c | sort -nr | sed 's:HTTP/1.1" 404:ошибок сервера с кодом 404 зафиксировано:' >> /bash-CRON/MESSAGE

#Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
echo -en "\n\nКоды HTTP ответа\n" >> /bash-CRON/MESSAGE
cat /bash-CRON/access.log | grep -Eo ".*HTTP/1\.1\" [1-5][0-9][0-9]" | grep -Eo '[1-5][0-9][0-9]' | sort | uniq -c | sort -nr >> /bash-CRON/MESSAGE

# Отправка email
cat /bash-CRON/MESSAGE
mail -s "$m_date Результаты c access.log " helloOTUS@gmail.com < /bash-CRON/MESSAGE

#удаляем файл блокировки
trap "rm /var/tmp/script.lock" EXIT

