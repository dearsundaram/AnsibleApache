####### This script will need to be executed on the RHEL servers especially while installing through AWS
#!/bin/bash
useradd sundar
echo "sundar:Rhel@2017" | chpasswd
echo 'ansibleslave ALL=(ALL) NOPASSWD: ALL' >> sudoers
cp /etc/sshd/sshd_config /etc/sshd/sshd_config_orig
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' sshd_config
