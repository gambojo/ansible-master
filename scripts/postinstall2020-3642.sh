#/bin/bash
#set -e

function logging () {
    echo -e "$(date +%H:%M.%S) \t $1 \t $2" >> /tmp/postinstall.debug
}

logging "main" "Скрипт начал работу"
srvrepo=yuo-repo-01.rosgvard.ru
srvkesl=10.3.72.45
srvdc=SKO3642-DC-01
loginadm=Agamovga
password=Qwerty_5581gama
NEED_INSTALL="ssh fly-admin-ad-client puppet-agent ntpdate klnagent64-astra kesl"
tmpfile=/tmp/tmpfile.pstnstl
logfile=/var/log/postinstall.log
sudo touch $logfile
sudo chmod 774 $logfile
sudo chown root:service $logfile
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
DIALOG=dialog

logging "main" "Заполнены все переменные"
which dialog >> /dev/null
AVAIL_DIALOG=$?

function checkStatus {
if [ $1 -eq 0 ]; then
    echo -n "${green}${toend}[OK]"
else
    echo -n "${red}${toend}[fail]"
fi
echo -n "${reset}"
echo ""
}

USER_ID=$(id -u)
id -G | grep 333 >> /dev/null
GROUP_ID=$?
logging "main" "Пользователь инициализирован"
logging "main" "USER_ID=$USER_ID"
logging "main" "GROUP_ID=$GROUP_ID"
if ! ( [[ $USER_ID -eq 0 || $GROUP_ID -eq 0 ]] ) ; then
logging "main" "Не тот пользователь"
    if [ $AVAIL_DIALOG -eq 0] ; then
        logging "main" "Не тот пользователь. Диалог установлен"
        $DIALOG --title "Ошибка пользователя" --clear --msgbox "Скрипт должен быть запущен пользольвателем находящимся в группе astra-admins, либо root." 10 40
        clear
        exit 1;
    else
    logging "main" "Не тот пользователь. Диалога нет"
    echo "Скрипт должен быть запущен пользольвателем находящимся в группе astra-admins, либо root."
    exit 1;
    fi
fi

logging "main" "Проверка наличии программы диалог AVAIL_DIALOG=$AVAIL_DIALOG"
if [ $AVAIL_DIALOG -ne 0 ] ; then
    logging "AVAIL_DIALOG" "Программа не установлена, сейчас исправим" 
    sudo wget -qO /tmp/rg_key.key  http://$srvrepo/rosgvard_gpg.key >> $logfile
    sudo apt-key add /tmp/rg_key.key >> $logfile

    sudo wget -qO /etc/apt/sources.list  http://$srvrepo/configs/apt/sources.list >> $logfile
    sudo wget -qO /etc/apt/apt.conf.d/99nonsrvfind http://$srvrepo/configs/apt/99nonsrvfind >> $logfile
    sudo apt-get update >> $logfile
    echo -e "Установка программы организации интерефейса" >>$logfile
    sudo apt  install dialog >> $logfile
    logging "AVAIL_DIALOG" "Установлено"
    checkStatus $?
fi

function show_main_menu {
logging "show_main_menu" "Зашли в функцию"
$DIALOG --backtitle "Скрипт настройки АРМ Росгвардии" \
        --title "Проверьте параметры, которые будут применены при выполнении скрипта" --clear \
        --yesno " Сервер-репозиторий             = $srvrepo \n\
Используемый контроллер домена = $srvdc \n \
Сервер антивирусной защиты     = $srvkesl\n
Имя компьютера в домене        = $hstnm\n\n\
Имя администратор домена       = $loginadm\n
Пароль администратора          = $password\n\n
В случае если все верно нажмите кнопку <Да>, если необходимо исправить какой нибудь пункт <Нет>" 20 80

case $? in 
    0)
    logging "show_main_menu_case" "Пользователь дал ответ ДА"
    IS_READY=0
    ;;
    1)
    logging "show_main_menu_case" "Пользователь дал ответ НЕТ"
    show_change_varible
    ;;
    255)
    logging "show_main_menu_case" "Пользователь нажал escape"
    show_error
    ;;
esac
}

function start_script {
    logging "start_script" "Вошли в функцию"
    $$DIALOG --title "Ошибка ввода" --clear \
            --msgbox "Начинаем установку всего" 20 80
}

function show_change_varible {
    logging "show_change_varible" "Защли в функцию"
    $DIALOG --clear --title "Изменение значения параметров" \
            --menu "Выберите параметр, который хотите изменить и нажмите enter, для возврата в предыдущее меню нажмите кнопку <Отмена>:" 20 80 4 \
            "01. Сервер репозиторий" "$srvrepo" \
            "02. Контроллер домена" "$srvdc" \
            "03. Сервер антивирусной защиты" "$srvkesl" \
            "04. Имя компьютера в домене" "$hstnm"  2> $tmpfile
    if [[ $? -eq 1  || $? -eq 255 ]] ; then
        show_main_menu
        logging "show_change_varible" "Пользователь нажал отмена"
        retutn 0
    fi
    SELECT_NUM_MENU=$(cat $tmpfile | cut -f 1 -d. | sed -e 's/^[0]*//')
    SELECT_NAME_MENU=$(cat /tmp/tmpfile.pstnstl  | cut -f2 -d.)

    if [ -z $SELECT_NUM_MENU] ; then
        return 0
    fi

    logging "show_change_varible" "Пользователь выбрал в меню пункт $SELECT_NUM_MENU"

    $DIALOG --backtitle "Скрипт настройки АРМ Росгвардии" \
                    --title "Изменение параметра $NAME_NUM_MENU" --clear \
                    --inputbox "Введите новое значение для параметра $SELECT_NAME_MENU и нажмите кнопку <ОК>, для отмены нажмите кнопку <Отмена>" 20 80 2> $tmpfile
    case $? in
   0)
    logging "show_change_varible" "Пользователь нажал ОК"
    logging "show_change_varible" "SELECT_NUM_MENU=$SELECT_NUM_MENU"
    NEW_VALUE=$(cat $tmpfile)
    logging "show_change_varible" "NEW_VALUE=$NEW_VALUE"
    case $SELECT_NUM_MENU in
    1)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение cервера репозитория на $(cat $tmpfile)"
        srvrepo=$NEW_VALUE
        logging "show_change_varible_case_1" "новое значение параметра $srvrepo"
        ;;
    2)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение адреса контроллера домена на $(cat $tmpfile)"
        srvdc=$NEW_VALUE
        ;;
    3)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение сервер антивирусной защиты на $(cat $tmpfile)"
        srvkesl=$NEW_VALUE
        logging "show_change_varible_case_1" "новое значение параметра $srvkesl"
        ;;
    4)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение имени машины в домене на $(cat $tmpfile)"
        hstnm=$NEW_VALUE
        ;;
    5)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение имя аминистратора домена $(cat $tmpfile)"
        loginadm=$NEW_VALUE
        ;;
            
    6)
        logging "show_change_varible_case_1" "Пользователь хочет изменить значение пароля адмнистратора домена $(cat $tmpfile)"
        password=$NEW_VALUE
        ;;

       esac
    ;;
   1)
    logging "Пользователь нажал Отмена"
    show_main_menu
   ;;
   255)
    logging "show_change_varible" "Пользователь не решил что именно будет менять"
    show_error
    ;;
esac
show_change_varible
}



function show_error {
    logging "show_error" "Зашли в функцию"
    $DIALOG --title "Нажат escape" --clear \
            --yesno "Хотите выйти?" 20 80
    case $? in
        0) 
            clear
            exit 0;
            ;;
        1)
            show_main_menu
            ;;
        255)
            show_main_menu
            ;;
    esac
    clear
}

logging "main" "Выводим приветствие"
$DIALOG --backtitle "Скрипт настройки АРМ Росгвардии" \
                    --title "Введите имя компьютера, с которым он будет введен в домен" --clear \
                    --inputbox "Вы запустили скрипт настройки автоматизированного рабочего места Федеральной службы войск национальной гвардии Российской Федерации. Введите имя компьютера в домене и нажмите кнопку <OК>, для того что бы ввести в домен с текущем именем нажмите на кнопку <Отмена>" 20 80 2> $tmpfile
case $? in
   0)
    logging "main" "Пользователь решил ввести новое имя машины `cat $tmpfile`"
    hstnm=$(cat $tmpfile)
   ;;
   1)
    logging "main" "Пользователь решил оставить имя машина имя машины $(hostname) "
    hstnm=$(hostname)
   ;;
   255)
    logging "main" "Пользователь не решил что сделать с именем машины "
    show_error
    ;;
esac
clear
IS_READY=1
    logging "main" "Значение IS_READY=$IS_READY" 
until [ $IS_READY -eq 0 ]
do 
    logging "main" "Зашли в цикл главного окна" 
    show_main_menu
    logging "main" "Результат выполения главного окна $IS_READY" 
    clear
done
clear


#1. Скачиваем файл со списком репозиториев
echo -e "Скачиваем файл с списком репозиториев"
sudo wget -qO /etc/apt/sources.list  http://$srvrepo/configs/apt/sources.list 2>&1>> $logfile
checkStatus $?
#2. Добавляем ключ для репозитория
echo -e "Добавляем ключ для репозитория..."
wget -qO -  http://$srvrepo/rosgvard_gpg.key | sudo apt-key add  2>&1 >> $logfile
checkStatus $?
#3. Отключаем проверку SRV записей для репозитория
sudo wget -qO /etc/apt/apt.conf.d/99nonsrvfind http://$srvrepo/configs/apt/99nonsrvfind 2>&1>> $logfile
checkStatus $?
#3.1 Обновляем список  пакетов в репозиториях
echo -e "Обновляем список  пакетов в репозиториях"
sudo apt update  >> $logfile
#4. Устанавливаем программы
for i in $NEED_INSTALL
do
    echo -e "Устанавливаем $i"
    sudo apt install $i -y  2> /dev/null >> $logfile
    checkStatus $?
done
#4.1 Устанавливаем дополнительные программы
echo -e "Устанавливаем дополнительные программы"
apt -y install cups-drv-astralinux remmina remmina-plugin-rdp gimagereader doublecmd-common dia imagemagick gis-client myoffice-presentation-editor-linux cifs-utils djview4 libreoffice libreoffice-l10n-ru evince nautilus simple-scan 

#5. установка библиотек для 32 драйверов
echo -e "установка библиотек для 32 драйверов"
apt install ia32-libs lsb cups-drv-astralinux

#6. Создаем файл конфигурации для Агента касперского
echo -e "Создаем файл конфигурации для Агента касперского"
echo "KLNAGENT_SERVER=$srvkesl
KLNAGENT_PORT=14000
KLNAGENT_SSLPORT=13000
KLNAGENT_USESSL=y
KLNAGENT_GW_MODE=1" > $tmpfile && cp $tmpfile /tmp/autoanswers.conf
checkStatus $?
#7. Запускаем постинсталл агента касперского
echo -e "Запускаем постинсталл агента касперского"
cd /tmp/
sudo /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl --auto 2>&1>> $logfile
checkStatus $?
#8.
echo -e " Создаем файл конфигурации для касперского"
echo "EULA_AGREED=yes
PRIVACY_POLICY_AGREED=yes
USE_KSN=yes
SERVICE_LOCALE=ru_RU.UTF8
INSTALL_LICENSE=
UPDATER_SOURCE=SCServer
PROXY_SERVER=none
UPDATE_EXECUTE=no
KERNEL_SRCS_INSTALL=no
IMPORT_SETTINGS=Yes
USE_GUI=yes
USE_FANOTIFY=no" > $tmpfile &&  cp $tmpfile /tmp/auto.ini
checkStatus $?
#9. Запускаем постинсталл касперского
echo -e "Запускаем постинсталл касперского"
sudo /opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/tmp/auto.ini 2>&1>> $logfile
checkStatus $?
#10. Создаем файл конфигурации для касперского
#11. решаем проблему обновления антивирусных баз через KSC.
sudo sed -i 's/.*::1     localhost ip6-localhost ip6-loopback.*/#::1     localhost ip6-localhost ip6-loopback/' /etc/hosts
#12. Настраиваем время
echo -e "Настраиваем время"
sudo systemctl stop ntp >> $logfile
sudo ntpdate rosgvard.ru >> $logfile
sudo hwclock -w >> $logfile
sudo wget -qO /etc/ntp.conf http://$srvrepo/configs/ntp/ntp.conf 2>&1>> $logfile
sudo systemctl start ntp >> $logfile
checkStatus $?
#13. Вводим в машину домен
echo -e "Вводим в машину домен"
sudo hostnamectl set-hostname $hstnm >> $logfile
sudo astra-winbind -dc $srvdc.rosgvard.ru -u $loginadm -p $password -y >> $logfile
checkStatus $?
#14. Настраиваем паппет
echo -e "Настраиваем паппет"
sudo wget -qO /etc/puppetlabs/puppet/puppet.conf http://$srvrepo/configs/puppet/puppet.conf 2>&1>> $logfile
sudo /opt/puppetlabs/bin/puppet agent -t >> $logfile
checkStatus $?
#15. Запускаем ssh
echo -e "Запускаем ssh"
sudo systemctl start ssh  >> $tmpfile && sudo systemctl enable ssh 2>&1>> $logfile
checkStatus $?
#16. Настраиваем вывод имя пользователя на lockscreen
echo -e "Настраиваем вывод имя пользователя на lockscreen"
sudo sed -i 's/PreselectUser=None/PreselectUser=Previous/' /etc/X11/fly-dm/fly-dmrc 2>&1>> $logfile
checkStatus $? 
#17. включаем последнего пользователя
echo "[PrevUser]" | sudo tee /var/lib/fly-dm/fly-dmsts 
echo "%3A0="$usrnm"@rosgvard.ru" | sudo tee   /var/lib/fly-dm/fly-dmsts
checkStatus $? 
#18. Включаем numlock при загрузке
echo -e "Включаем numlock при загрузке" 
sudo sed -i 's/numLockOn=false/numLockOn=true/' /usr/share/fly-wm/theme/default.themerc 2>&1>> $logfile
checkStatus $?
