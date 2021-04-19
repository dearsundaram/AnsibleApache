# Automation of Website creation using Ansible

## Core Idea

The idea is to automate the creation of a shopping cart website using Ansible


## Architecture Diagram

The below architecture diagram is the layout for the website. It has 3 major entities

1. **Apache Web Server** (2.4.x) on top of RedHat Linux
2. **PHP code** deployed on to Apache
3. **Maria DB** which has the complete list of products

![image](https://github.com/dearsundaram/AnsibleApache/blob/gh-pages/Architecture.jpeg.png?raw=true)

## Implementation Plan (Manual)

Below are the steps which needs to be performed manually for achieving the above model website

1. Create an RHEL instance using AWS EC2
2. Install Apache web server using OS repository
3. Install Firewalld 
4. Install PHP on to the same RHEL server
5. Install MariaDB 
6. Create the database and tables to store the necessary data required to load the products
7. Place the PHP script and necessary image files on to Apache's default directory path
8. Point the PHP code to the MariaDB server's IP address and port
9. Remove the firewall between the DB and HTTPD ports
10. Restart Database and Apache webserver


## Implementation Plan (Automation)
The entire process mentioned above can be automated in Ansible.

All we need is an EC2 instance running RHEL OS.

In order to keep the code simple and reusable, **Ansible Roles** methodology is implemented. I have used _ansible galaxy_ to create and define the roles

The list of roles implemented for this project is given below :


![image](https://github.com/dearsundaram/AnsibleApache/blob/gh-pages/RolesFolder.png?raw=false)



Once the roles are created, the next step is to write the required playbooks for each and every role.

## Apache Playbook

This playbook will install the Apache web server from OS repo and will instruct mighty Apache to look for a php file to load its web page

```markdown

############ APACHE PLAYBOOK ###########
#- hosts: webservers
#  gather_facts: true
#  become_method: sudo
#  become_user: root
    - name: Install Apache from OS repo
      yum:
        name: httpd
        state: latest
      become: true
    
    - name: Configure Apache to use the php files instead of html files from its doc root
      replace:
        path: /etc/httpd/conf/httpd.conf
        regexp: index.html
        replace: index.php
        backup: yes
      become: true
 
    - name: Enable httpd service
      service:
        name: httpd
        enabled: yes
      become: true
    
    - name: Restart httpd service
      service:
        name: httpd
        state: restarted
      become: true
```



## MariaDB Installation Playbook

Maria DB is also installed from OS repository and it service is enabled

```markdown

################### MARIADB PLAYBOOK ###############

    - name: Install Maria DB from OS repo
      yum:
        name: mariadb-server
        state: latest
      become: true

    - name: Enable Maria DB service
      service:
        name: mariadb
        enabled: yes
      become: true

    - name: Start Maria DB service
      service:
        name: mariadb
        state: restarted
      become: true
```

## Firewalld Installation Playbook


Firewalld is an important module which will help in removing the firewall between Apache and MariaDB. 

As you can see below, after installing firewalld from repo, we have removed the firewall for port 80 (httpd) and port 3306 (MariaDB)

```markdown

############## FIREWALLD PLAYBOOK ###########

    - name: Install Firewalld module from OS repo
      yum:
        name: firewalld
        state: latest
      become: true

    - name: Enable Friewalld service
      service:
        name: firewalld
        enabled: true
      become: true

    - name: Remove firewall for HTTPD port 80
      firewalld:
        port: 80/tcp
        permanent: yes
        state: enabled
      become: true
    
    - name: Remove firewall for Maria DB port 3306
      firewalld:
        port: 3306/tcp
        permanent: yes
        state: enabled
      become: true

    - name: Start firewalld service
      service:
        name: firewalld
        state: restarted
      become: true
```

## Database and Table configuration Playbook

After configuring the firewall, the next step is to configure the database to load the cart information

To achieve this, we are installing multiple modules
1. Install mysql module using pip3 
2. Install php-mysqli module so that the SQL queries gets executed under the php tag

```markdown

########## SQL PLAYBOOK ###############
    - name: Install  pip3
      yum:
        name: python3-pip
        state: latest
      become: true

    - name: Install required MySQL modules using pip3
      pip:
        name: PyMySQL
        state: latest
      become: true

    - name: Install mysqli for connecting to DB through php
      yum:
        name: php-mysqli
        state: latest
      become: true

    - name: Create a new database with name 'ecomdb'
      mysql_db:
        name: ecomdb
        state: present
      become: true
    
    - name: Create database user with name 'bob' and password '12345' with all database privileges
      mysql_user:
       name: ecomuser
       password: ecompassword
       priv: '*.*:ALL,GRANT'
       state: present
      become: true
    
    - name: Flush Privileges
      shell: mysql -e "FLUSH PRIVILEGES;"
      become: true

    - name: Creating db-load-script.sql file
      copy:
        dest: "/root/db-load-script.sql"
        content: |
          USE ecomdb;
          CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
          INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
      become: true

    - name: Run the db-load-script.sql file
      shell: mysql < /root/db-load-script.sql
      become: true

    - name: Sanity Restart httpd service
      service:
        name: httpd
        state: restarted
      become: true
```

## PHP Installation Playbook

PHP code is taken from https://github.com/kodekloudhub/learning-app-ecommerce.git repo. This is the code which is going to design our shopping cart website.

Courtesy : Mumshad Mannambeth

The entire PHP code is copied under /var/www/html folder which is the default web page path for Apache. Also. we are also adding the database server's IP and port number in the index.php file


```markdown

########## PHP and GIT DOWNLOAD PLAYBOOK ##########
    ####### Install prerequisistes ######
    - name: Install php package
      yum:
        name: php
        state: installed
      become: true
    
    - name: Install git package
      yum:
        name: git
        state: installed
      become: true

    ########## Clone the GIT repository which has php code #######
    - name: Clone a repo with separate git directory
      ansible.builtin.git:
         repo: https://github.com/kodekloudhub/learning-app-ecommerce.git
         dest: /var/www/html
         clone: yes
         force: yes
      become: true

    - name: Configure Apache to use the php files instead of html files from its doc root
      replace:
        path: /var/www/html/index.php
        regexp: 172.20.1.101
        replace: localhost
        backup: yes
      become: true
```

## After creating all these role, they are invoked in the main ansible script as below 


The main ansible playbook name is **AnsibleApache.yml**

```markdown

---
- hosts: webservers
  gather_facts: true
  become_method: sudo
  become_user: root
  roles:
    - apache
    - mariadb
    - firewall
    - php_git
    - sqlinit
```


# SIMULATION 

To simulate this, we need at least two servers. One server will act as an Ansible controller where this entire playbooks will be created

The other server will act as Ansible Slave, in which the actual setup for the website is created.

For simulation purpse, we have installed **Apache**, **PHP**, **MariaDB** on the same server.

Both Ansible controller and Ansible slave is created as an EC2 instance (Thanks to AWS free tier !! )


![image](https://github.com/dearsundaram/AnsibleApache/blob/gh-pages/AWS_Instances.png?raw=false)


The entire playbook is pushed to **AnsibleApache** (Ansible Master) using git client

Now the main playbook **AnsibleApache.yml** will be executed as below 


```markdown

[ansiblecontrol@ip-172-31-28-108 AnsibleApache]$ ansible-playbook AnsibleApache.yml 

PLAY [webservers] *******************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [172.31.58.102]

TASK [apache : Install Apache from OS repo] *****************************************************************************************************************
changed: [172.31.58.102]

TASK [apache : Configure Apache to use the php files instead of html files from its doc root] ***************************************************************
changed: [172.31.58.102]

TASK [apache : Enable httpd service] ************************************************************************************************************************
changed: [172.31.58.102]

TASK [apache : Restart httpd service] ***********************************************************************************************************************
changed: [172.31.58.102]

TASK [mariadb : Install Maria DB from OS repo] **************************************************************************************************************
changed: [172.31.58.102]

TASK [mariadb : Enable Maria DB service] ********************************************************************************************************************
changed: [172.31.58.102]

TASK [mariadb : Start Maria DB service] *********************************************************************************************************************
changed: [172.31.58.102]

TASK [firewall : Install Firewalld module from OS repo] *****************************************************************************************************
changed: [172.31.58.102]

TASK [firewall : Enable Friewalld service] ******************************************************************************************************************
ok: [172.31.58.102]

TASK [firewall : Remove firewall for HTTPD port 80] *********************************************************************************************************
changed: [172.31.58.102]

TASK [firewall : Remove firewall for Maria DB port 3306] ****************************************************************************************************
changed: [172.31.58.102]

TASK [firewall : Start firewalld service] *******************************************************************************************************************
changed: [172.31.58.102]

TASK [php_git : Install php package] ************************************************************************************************************************
changed: [172.31.58.102]

TASK [php_git : Install git package] ************************************************************************************************************************
changed: [172.31.58.102]

TASK [php_git : Clone a repo with separate git directory] ***************************************************************************************************
changed: [172.31.58.102]

TASK [php_git : Configure Apache to use the php files instead of html files from its doc root] **************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Install  pip3] ******************************************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Install required MySQL modules using pip3] **************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Install mysqli for connecting to DB through php] ********************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Create a new database with name 'ecomdb'] ***************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Create database user with name 'bob' and password '12345' with all database privileges] *****************************************************
changed: [172.31.58.102]

TASK [sqlinit : Flush Privileges] ***************************************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Creating db-load-script.sql file] ***********************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Run the db-load-script.sql file] ************************************************************************************************************
changed: [172.31.58.102]

TASK [sqlinit : Sanity Restart httpd service] ***************************************************************************************************************
changed: [172.31.58.102]

PLAY RECAP **************************************************************************************************************************************************
172.31.58.102              : ok=26   changed=24   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```


## Website hosted on new Ansible Slave server ##


![image](https://github.com/dearsundaram/AnsibleApache/blob/gh-pages/FinalWebPage.png?raw=false)


# BENEFITS OF ANSIBLE AUTOMATION

This entire process on manual mode will take atleast 2 hours to complete for a single server and may extend if anything is missed in the process.

However, after automating the same set of instructions using ansible, it only take 5-7 mins to setup the entire website per server without any manual errors..!!!
