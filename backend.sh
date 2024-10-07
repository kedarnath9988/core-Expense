#!/bin/bash

USER=$(id -u )
TIME_STAMP=$( date +%F-%H-%M-%S )
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
echo "please enter the mysql passwd "
read PASSWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 done successfully $N"
    else
        echo -e "$R $2 failure .. $N "
        exit 1 # manually exiting 
    fi 
}

if [ $USER -eq 0 ]
then
    echo -e "$G  you are the super-user $N"
else
    echo -e "$R need super user access $N"
    exit 1 # exiting manually 
fi 

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling node 20 "

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id expense
if [ $? -eq 0 ]
then
    echo -e "$G user already existed $N"
else
    useradd expense 
    echo -e "$R  expense user added succesfully"
fi 

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "crating /app "

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "downloeding backend code "

cd /app
rm -rf /app/*&>>$LOG_FILE
VALIDATE $? "removing content in /app dir "

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "downloeding backend code "

npm install &>>$LOG_FILE
VALIDATE $? "downloeding nodejs dependeces"

cp /home/ec2-user/core-Expense/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "copying the backend service "
systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "daemon-reload"
systemctl enable  backend &>>$LOG_FILE
VALIDATE $? "enable  backend"
systemctl start backend &>>$LOG_FILE
VALIDATE $? "start backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "install mysql clint "

mysql -h db.dawskedarnath.online -uroot -p${PASSWD} < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "mysql root password  "

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "start backend"

