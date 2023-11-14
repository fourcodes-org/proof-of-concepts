## 1. ERROR

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a23e0845-3aeb-42f9-9d0f-893d6a3a0fa7)

_Solution_
-----------

we need to give the vsftpd user permission for the document root.

    sudo chmown -R (vsftpd_username) /var/www/html               # /var/www/html - is a Document Root
