CREATE USER 'replica'@'%' IDENTIFIED BY 'replica';
GRANT REPLICATION ON *.* TO 'replica'@'%';
