# Welcome to GitHub Pages

This is my little project with Ansible Automation.

## Core Idea

The idea is to automate the creation of a shopping cart website using Ansible


## Architecture Diagram

The below architecture diagram is the layout for the website. It has 3 major entities

1. **Apache Web Server** (2.4.x) on top of RedHat Linux
2. **PHP code** deployed on to Apache
3. **Maria DB** which has the complete list of products

![image](https://github.com/dearsundaram/AnsibleApache/blob/gh-pages/Architecture.jpeg.png?raw=true)

## Implementation Plan

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

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/dearsundaram/AnsibleApache/settings/pages). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://support.github.com/contact) and we’ll help you sort it out.
