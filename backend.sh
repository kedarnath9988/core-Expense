#!/bin/bash 

USER=$(id -u )
TIME_STAMP=$ (date +%F-%H-%M-%S )
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=/tmp/-$SCRIPT_NAME-$TIME_STAMP.log
echo "please enter the mysql password"
read MYSQL_PASSWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 done successfully ..$N"
    else
        echo -e "$R $2 .. failure $N"
        exit 1 
    fi 
}

if [ $USER -eq 0 ]
then
    echo -e "$G you are the super-user $N"
else
    echo -e "$R need super user access to do $N"
    exit 1 # manually exiting 
fi 


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql-server "


systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "ebaling mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "starting mysqld"

mysql -h db.dawskedarnath.online -urrot -p${MYSQL_PASSWD} -e 'show databases'
if [ $? -eq 0 ]
then 
    echo "mysql password already setuped"
else
    mysql_secure_installation --set-root-pass ${MYSQL_PASSWD} &>>$LOG_FILE
    VALIDATE $? "mysql password setting "
fi  
