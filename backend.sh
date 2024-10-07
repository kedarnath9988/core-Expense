#!/bin/bash

USER=$(id -u )
TIME_STAMP=$( date +%F-%H-%M-%S )
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER -eq 0 ]
then
    echo -e "$G  you are the super-user $N"
else
    echo -e "$R need super user access $N"
    exit 1 # exiting manually 
fi 

