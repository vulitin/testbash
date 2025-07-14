#!/bin/bash

SERVER="test"
DATE=$(date "+%d_%m_%Y")
URL=https://raw.githubusercontent.com/GreatMedivack/files/master/list.out

wget $URL

# Проверка параметра на существование
if [ "$1" != "" ]; then
    echo "SERVERNAME is $1"
    SERVER=$1
else
    echo "No SERVERNAME parameter provided"
fi

#Фильтрация и разбиение на подфайлы
awk '$3 == "Error" || $3 == "CrashLoopBackOff" {print $1}' list.out | \
 sed 's/-[^-]\{9,10\}-[^-]\{5\}$//' > "${SERVER}_${DATE}_failed.out"

awk '$3 == "Running" {print $1}' list.out | \
 sed 's/-[^-]\{9,10\}-[^-]\{5\}$//' > "${SERVER}_${DATE}_running.out"

# Создание файла отчета
cat <<EOF >"${SERVER}_${DATE}_report.out"
"Количество работающих сервисов: $(wc -l < "${SERVER}_${DATE}_running.out")
Количество сервисов с ошибками: $(wc -l < "${SERVER}_${DATE}_failed.out")
Имя системного пользователя: ${USER}
Дата: ${DATE}"
EOF

chmod 664 ${SERVER}_${DATE}_report.out

#Архивация и создание папки
tar -cf ${SERVER}_${DATE} ${SERVER}_${DATE}_*
mkdir archives
mv ${SERVER}_${DATE} ./archives/

#Удаление всех файлов
rm -r *.out

#Проверка архива
((tar -tf ./archives/${SERVER}_${DATE}) && \
(tar -xvf ./archives/${SERVER}_${DATE} -O > /dev/null)) && \
echo "All checkings completed. Arcrive is OK!" || \
echo "Error! Archive is damaged."