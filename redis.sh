#! /bin/bash
USERID=$(id -u) #if id -u = 0 then it is root user else non root user
LOGS_FOLDER="/var/log/shell-script" 
LOGS_FILE="$LOGS_FOLDER/$0.log" 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "disabling all versions of redis module"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "enabling version:7 of redis"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? " Installing redis "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? " allowing to all 0.0.0.0"

sed -i 's/yes/no/g' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? " protected-mode from yes to no configuration "


systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "enabling redis..."

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "starting redis..."


