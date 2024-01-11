# ERROR
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a19b3388-9de1-4f4a-b89a-4f20ac9330ff)

_**Solution:**_
We must use the specified document root in the specific vhost domain.
```sh
certbot certonly --webroot -w /var/www/ashli -d ashli.januo.io
```
> [!NOTE]
> https://www.server-world.info/en/note?os=Ubuntu_22.04&p=ssl&f=2

**output**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/deb7f394-9e4b-4df6-bf9a-29ac442834f3)
