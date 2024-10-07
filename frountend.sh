#!/bin/bash
USER=$(id -u )
TIME_STAMP=$( date +%F-%H-%M-%S )
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx "

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx "

systemctl start  nginx &>>$LOG_FILE
VALIDATE $? "start nginx "

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing default content in nginx "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOG_FILE
VALIDATE $? "downlode  frontend code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "removing default content in nginx"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip frontend code"

cp /home/ec2-user/core-Expense/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "copying the conf file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restaring the nginx"



