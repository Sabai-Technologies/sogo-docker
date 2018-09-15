### SOGo Docker image ###
Docker image for SOGo based on the nightly build package of Inverse.

[SOGo](https://sogo.nu/) is free and open source groupware server for sharing calendars, address books, mail. 
SOGo supports use of standard protocols such as CalDAV, CardDAV and GroupDAV, as well as Microsoft ActiveSync.


## Features ##
* Support MySQL
* Autoconfigure database
* Dynamic configuration based on the SOGo variable name

## Supported tags ##
* **latest**

## Detailed Configuration ##
- ### Port ###
  - 20000

- ### Environment variables ###
    - #### MySQL ##### 
      * **MYSQL_SERVER**:  MySQL/Maria DB Server name or ip
      * **MYSQL_PORT** (default is *3306*): port used by the database server
      * **MYSQL_ROOT_PASSWORD** (required if **MYSQL_SERVER** is set): root user is required to create SOGo database
      * **MYSQL_USER** (required if  **MYSQL_SERVER** is set): MYSQL user used by SOGo
      * **MYSQL_USER_PASSWORD** (required i **MYSQL_SERVER** is set): password for MYSQL_USER
      * **MYSQL_DATABASE_NAME** (default is sogo): name of the database
    - #### SOGo Configuration #####
      * **WORKERS_COUNT** (default is 5) : number of SOGo child process that will be used to handle requests.
      (useful when using ActiveSync)
      * **SOGO_SogoConfigurationVariable** : set value for SOGo variable *SogoConfigurationVariable*. 
      See the online [documentation](https://sogo.nu/files/docs/SOGoInstallationGuide.html).

- ### MySQL
    For a fresh installation, you have to provide all the information about the database to create tables 
    required by SOGo. Nothing will be done if the tables already exist.
    
    The information provided by the **MYSQL_** variables are used to define SOGo variables *OCSSessionsFolderURL*, 
    *OCSFolderInfoURL*,  *SOGoProfileURL*.
    
    It will overrides the ones define by *SOGO_OCSSessionsFolderURL*, *SOGO_OCSFolderInfoURL*, *SOGO_SOGoProfileURL*

- ### SOGo configuration
    To configure SOGo, you can use environment variable based on SOGo variable name and the *SOGO_* prefix.
    
    You can also configure by executing commands like:
    ```
    docker-compose exec sogo sh -c 'defaults write sogod "SogoVariable" "value"'
    docker-compose restart
    ```
    
    To get a dump of the SOGo configuration, you can execute the following command:
    ```
    docker-compose exec sogo sh -c 'sogo-tool dump-defaults'
    ```
    
    
## docker-compose.yml example ##
  ```yml
version: '2'

services:
  sogo:
    image: sabaitech/sogo
    container_name: sogo
    ports:
        - 20000:20000
    environment:
        - MYSQL_SERVER=mariadb
        - MYSQL_ROOT_PASSWORD=test
        - MYSQL_USER=sogo
        - MYSQL_USER_PASSWORD=sogoPassword
        - MYSQL_DATABASE_NAME=sogo
        - SOGO_SOGoIMAPServer="imaps://imap.server.com:143/?tls=yes"
        - SOGO_SOGoSMTPServer=smtp.server.com
        - SOGO_SOGoMailDomain=server.com
        - SOGO_SOGoMailingMechanism=smtp
        - SOGO_SOGoSMTPAuthenticationType=PLAIN
        - SOGO_SOGoForceExternalLoginWithEmail=YES
        - SOGO_NGImap4ConnectionStringSeparator="."
        - SOGO_SOGoPasswordChangeEnabled=NO
        - SOGO_SOGoForwardEnabled=YES
        - SOGO_SOGoSieveScriptsEnabled=YES
        - SOGO_SOGoTimeZone=Europe/Paris
        - SOGO_WorkersCount=4
        - SOGO_SOGoCalendarDefaultRoles=("PublicDAndTViewer","ConfidentialDAndTViewer","PrivateDAndTViewer")
        - SOGO_SOGoUserSources=({
              canAuthenticate = YES;
              displayName = "SOGo Users";
              id = users; isAddressBook = YES;
              type = sql;
              userPasswordAlgorithm = md5;
              viewURL ="mysql://sogo:sogoPassword@mariadb:3306/sogo/sogo_users";
              KindFieldName = kind;
              MultipleBookingsFieldName = multiple_bookings;
          })

  nginx:
    image: nginx
    container_name: nginx
    links:
        - sogo
    volumes_from:
        - sogo:ro
    ports:
        - 80:80
    volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf:ro

  mariadb:
    image: mariadb:10.1
    container_name: mariadb
    environment:
        - MYSQL_ROOT_PASSWORD=test
    ports:
        - 3306:3306
    volumes:
        - "./data:/var/lib/mysql"
```