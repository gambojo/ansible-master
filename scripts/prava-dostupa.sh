#!/bin/bash
# Скрипт назначения владельца и выделения ему прав доступа

	# Инструкция
	echo "Введите имя учетной записи, не указывая домен"

	# Чтение водимых данных
	read VALUE

	# Назначаем владельца
	echo "Назначаем владельца домашнего каталога"
	sudo chown -R $VALUE@rosgvard.ru:"ROSGVARD\пользователи домена" /home/ROSGVARD/$VALUE
	echo "Даем полные права доступа к домашнему каталогу"
	sudo chmod -R u+rwx /home/ROSGVARD/$VALUE
	echo "Права присвоены"
	
	# Разрешаем флеш-накопители
	sudo usermod -aG floppy $VALUE@rosgvard.ru
	echo "Даем разрешение на использование флеш-накопителей"
	echo "Выйдите из системы и войдите снова"

# Завершение скрипта