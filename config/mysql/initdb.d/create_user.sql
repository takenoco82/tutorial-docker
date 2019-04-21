DROP USER IF EXISTS 'admin';
CREATE USER `admin`@`%` IDENTIFIED BY 'admin';

GRANT ALL PRIVILEGES ON *.* TO `admin`@`%`;
