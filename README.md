# Steps to start the db server.

1. Command 1 - git clone https://github.com/skalimuthu1/oracle-poc1.git
2. Command 2 - cd oracle-poc1
3. Command 3 - docker build . -t oracle-poc1
4. Command 4 - docker run -p 1521:1521 --name oracle-poc1 oracle-poc1

Wait till you see the below logs in your console: [It takes around 8 to 10 mins]
<img width="544" height="458" alt="image" src="https://github.com/user-attachments/assets/d4e00022-392a-41ed-b090-bbd2df07dcf2" />

Connecting to DB server from SQLDeveloper:
password is app_123 and can be configured in the Dockerfile

<img width="572" height="368" alt="image" src="https://github.com/user-attachments/assets/83e54039-8e1b-4583-8cdc-78b58be8b17b" />
