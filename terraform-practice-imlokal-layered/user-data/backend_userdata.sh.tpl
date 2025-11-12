#!/bin/bash -xe
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-headless awscli || true
mkdir -p /opt/imlokal/backend
cd /opt/imlokal/backend
APP_S3_URL="${app_s3}"
if [ -n "$APP_S3_URL" ]; then
  aws s3 cp "$APP_S3_URL" app.jar || true
fi
if [ -f app.jar ]; then
  cat > /etc/systemd/system/imlokal-backend.service <<'SERVICE'
[Unit]
Description=imlokal Backend
After=network.target
[Service]
User=root
WorkingDirectory=/opt/imlokal/backend
ExecStart=/usr/bin/java -jar /opt/imlokal/backend/app.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
SERVICE
  systemctl daemon-reload
  systemctl enable --now imlokal-backend.service || true
else
  cat > /opt/imlokal/backend/Hello.java <<'JAVA'
import java.io.*;
import java.net.*;
public class Hello {
  public static void main(String[] args) throws Exception {
    ServerSocket ss = new ServerSocket(8080);
    while (true) {
      Socket s = ss.accept();
      PrintWriter out = new PrintWriter(s.getOutputStream());
      out.print("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<html><body><h1>Backend Placeholder</h1></body></html>");
      out.flush(); s.close();
    }
  }
}
JAVA
  /usr/bin/javac /opt/imlokal/backend/Hello.java || true
  nohup /usr/bin/java -cp /opt/imlokal/backend Hello > /var/log/hello.log 2>&1 &
fi
