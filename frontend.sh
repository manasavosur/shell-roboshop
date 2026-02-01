#! /bin/bash
USERID=$(id -u) #if id -u = 0 then it is root user else non root user
LOGS_FOLDER="/var/log/shell-script" 
LOGS_FILE="$LOGS_FOLDER/$0.log" 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR=$PWD

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

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "disabling all nginx versions"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "enabling nginx version 1.24"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "deleting nginx default hrml format"

if [ -f /tmp/frontend.zip ]; then
    echo -e "$Y frontend code already downloaded... unzipping $N" | tee -a "$LOGS_FILE"
else
    curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>"$LOGS_FILE"
    VALIDATE $? "downloading frontend code"
fi

cd /usr/share/nginx/html &>>"$LOGS_FILE"

unzip -o /tmp/frontend.zip &>>"$LOGS_FILE"
VALIDATE $? "unzipping frontend code"


# Backup existing nginx.conf if exists
if [ -f /etc/nginx/nginx.conf ]; then
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back &>>$LOGS_FILE
    VALIDATE $? "backing up existing nginx.conf"
fi

# Copy custom nginx.conf
cp "$SCRIPT_DIR/nginx.conf" /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "copying custom nginx.conf"


systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "restarting nginx"
