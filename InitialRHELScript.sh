####### This script will need to be executed on the RHEL servers especially while installing through AWS
#!/bin/bash
useradd ansibleslave
echo "ansibleslave:Rhel@2017" | chpasswd
echo 'ansibleslave ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_orig
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd