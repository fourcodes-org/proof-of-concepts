![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/25a69358-d74e-4aa3-ad3a-981657afac3c)

Sol:
----
 - When we create a docker container using docker image we must correctly assign the Ports for appropriate actions.
   suppose if we are using apache2 and nginx nameservers,
       sudo docker run -it -d -p 8000:80 --name (containerName) (imageName)
