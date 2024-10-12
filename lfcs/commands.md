## 1 - Essential commands

```bash
sed -i '500,2000 s/enabled/disabled/gi' values.conf # lines
sed -i 's~#%$2jh//238720//31223~$2//23872031223~g' /home/bob/data.txt # non-alphanumeric 

egrep -o '[A-Z][a-z]{2,}' /etc/nsswitch.conf # 1 capital and 2 min. lowercase
egrep '[0-9]{5}' textfile > number # match a 5 digit number

grep '^2' textfile | wc -l # count of numbers starting with 2
grep -c '^2' textfile # count of numbers starting with 2

egrep -w 'man' testfile # exact word
egrep -wo 'man' testfile # exact word and only the matched word

# del many lines in vim: Make sure the cursor is on the very first line; then without entering into the insert mode, enter number 1000 and press dd immediately after that. Finally save the file.

sudo tar -cPzf logs.tar.gz /var/log/ # Create, absolute Path, gZip, File (archive) name
tar -tPf logs.tar # list contents
tar -xf archive.tar.gz -C /tmp # extraction directory Changes

bash -x ./script.sh &> output.txt # both stdout and stderr, shows eXecuted commands explicitly (debugging)
bash ./script.sh > output.txt 2>&1 # both stdout and stderr

sort -duf /home/bob/values.conf # Sort the contents of the file alphabetically; Dictionary order, Unique values and Fold lower case.
sort -f values.conf | uniq -i # # Sort the contents of the file alphabetically + Fold lower case; unique values with case Ignored.

openssl req -newkey rsa:2048 -keyout priv.key -out cert.csr # generate a 4096-bit RSA private key and a Certificate Signing Request
openssl req -x509 -noenc -days 365 -keyout priv.key -out kodekloud.crt # self-signed cert; no Encryption for the private key, expires in 365 Days
openssl x509 -in /home/bob/my.crt -text | grep CN # inspect the Common Name
```

## 2 - Operations Deployment

```bash
sudo shutdown -p +120 # schedule a Poweroff in 2 hrs

systemctl list-units --type target # list active Targets to boot into
systemctl list-unit-files --type target # list all Targets to boot into
sudo systemctl set-default graphical.target

sudo journalctl -u ssh.service # check logs for Unit ssh.service
journalctl -e -f -p err -g '^b' -S 01:00 -U 02:00 -b 0 # jump to End, Follow, choose Priority, Grep, Start / Until, current Boot

dpkg --listfiles coreutils | egrep  "^/bin/" # List files of the coreutils pkg | grep for a particular directory
sudo apt search --names-only 'apache http' # search for the specified terms in pkg Names only

sudo find /etc/ -type f -name "sources*" # find the sources list for apt

du -sh /bin/ | egrep "[0-9]+[A-Z]+" -o # dusk usage Summary of the /bin/ directory; Human-readable
free --mega | awk 'NR==2 {print $2}' # get the total Memory in Megabytes; 2nd Row, 2nd Printed column; Human-readable

sudo xfs_repair /dev/vdb -v # repair an XFS filesystem; Verbose; has to be unmounted
sudo fsck.ext4 /dev/vda1 -fp # repair an ext4 filesystem; Force checking; automatic rePair (no questions); has to be unmounted

ps -eZ | grep sshd # all processes with SELinux labels
sudo chcon -t httpd_sys_content_t /var/index.html # Change the SELinux Type
sudo restorecon -R /var/log # Restore the correct (default) labels for every file and subdirectory
setenforce permissive # change the SELinux status
semanage user -l # list SELinux users

sysctl -w kernel.modules_disabled=1 # Turn on a kernel runtime parameter
vim /etc/sysctl.conf # modify kernel runtime parameters
sysctl -p # apply the changes

docker run --detach  --publish 9080:80 --name webinstance1 --restart always httpd # run an apache server, redirect port 9080 to the container's port 80

virsh list --all
virsh destroy VM1 # 'unplug' VM1
virsh undefine VM1 # remove VM1
virsh create /opt/testmachine2.xml # create a VM from a configuration file
virsh autostart VM2 # start VM2 on host boot

# set memory and restart if no OS is present on the VM:
virsh setmaxmem VM2 80M --config
virsh setmem VM2 80M --config
virsh destroy VM2
virsh start VM2

# create a VM from a predefined image
virt-install --import --vcpus 1 --memory 1024 --name kk-ubuntu \
 --disk /var/lib/libvirt/images/ubuntu-22.04-minimal-cloudimg-amd64.img \
 --os-variant ubuntu22.04 --graphics none 

```

## 3 - Users and Groups

```bash
sudo adduser --system apachedev # create a system account
sudo adduser jack --shell /bin/csh # add user & specify the default shell
sudo adduser sam --uid 5322 --in-group soccer # specify user id and group (primary)
sudo useradd -G soccer sam  --uid 5322 # specify user id and group (additional)

sudo deluser sam --remove-home # remove user and their home directory

sudo usermod jane --expiredate '2030-03-01' # set expire date on the account
sudo usermod jane -e -1 # remove expiration date on the accont
sudo usermod -a -G developers jane # add to Group 'developers' Additionally

sudo chage jane --lastday 0 # mark the password as expired to force the user to immediately change it on the enxt login
sudo chage jane -W 2 # set password expiration warning days

sudo addgroup cricket --gid 9875 # create group with a specific group id

sudo groupmod cricket --new-name soccer # change group name

ls -ltra /etc/skel/ # list files that are copeid on user creation to their home directory
sudo vim /etc/profile.d/hi.sh # add a script to be executed one very login

sudo vim /etc/security/limits.conf # impsoe resource limits on users and groups
ulimit -a # list current user limits

sudo vim /etc/sudoers # open the sudoers file, add '<user> ALL=(ALL) NOPASSWD: ALL' to bypass password input when invoking sudo


```

## 4 - Networking

```bash
ip -c a # w/ Color 
ip -c route # inspect Routes

resolvectl status # inspect Resolvers
sudo vim /etc/systemd/resolved.conf # modify resolutions settings, e.g. select default DNS for all interfaces
sudo systemctl restart systemd-resolved.service # restart for the configuration to be applied

sudo ip link set dev enpXsY up # bring the interface Device Up
sudo ip link set dev enpXsY down # bring the interface Device Down

sudo ip a add 143.3.231.5/24 dev enpXsY # Add an ipv4 address to Device 
sudo ip a add fa10::4942:ff:fe2b:2922/64 dev enpXsY # Add an ipv6 address to Device
sudo ip a delete fa10::4942:ff:fe2b:2922/64 dev enpXsY # Delete an ipv6 address to Device

sudo netplan try --timeout 30 # Try with a custom Timeout
sudo netplan apply # Apply straightaway 
ls /usr/share/doc/netplan/examples/ # list netplan examples

#### Socket statistics

sudo ss -tulpn # TCP, UDP, Listening, Processes, Numeric values for socket statistics
sudo ss -tulpn | grep :22 | awk '{print $7}' | awk -F '[,=]' '{print $3}' # find out what Process is Listening for incoming connections on port 22 and identify PID; Field separators are ',' and '='
sudo ss -tulpn | awk 'NR>1 {print $5}' | egrep -o '[0-9]+$' # find LISTEN (tcp) or UNCONN (udp) port numbers

#### Firewall basics

sudo ufw status numbered # Status of the uncomplicated firewal; rules are Numbered
sudo ufw deny out on enpXsY to 8.8.8.8 # Deny Outgoing traffic from Device x to ip y
sudo ufw insert 1 deny from 10.0.0.19 # Insert a rule at the top of the rules table, i.e. it takes priority
sudo ufw allow in on enpXsY from 10.0.0.192 to 10.0.0.100 proto tcp # example in
sudo ufw allow out on enpXsY from 10.0.0.100 to 10.0.0.192 proto tcp # example out

sudo vim /etc/sysctl.d/99-sysctl.conf # enable ipv4 forwarding by uncommenting the 'net.ipv4.ip_forward=1' line
sudo sysctl --system # apply the changes

# Port redirection

man ufw-framework # / for 'DNAT' to find NAT and Masquerading examples

sudo iptables -t nat -A PREROUTING -p tcp -i ethX --dport 8080 -s 192.168.0.0/24 -j DNAT --to-destination 10.0.0.2:80 # redirect packets from Source:dport to Destination
sudo iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o ethX -j MASQUERADE # masquerade the redirected packets: the destination sees the current host as the source of the packets

sudo apt install iptables-persistent # install the package to allow iptables persistence
sudo netfilter-persistent save # persist the iptables changes

sudo iptables --list-rules --table nat # list nat rules
sudo iptables --flush --table nat # reset the nat table

# Configure SSH
sudo vim /etc/ssh/sshd_config # configure the ssh Daemon
ls /etc/ssh/sshd_config.d/ # list additional configuration files
sudo systemctl reload ssh.service

ssh-keygen -R 10.0.0.12 # remove fingerprint for a server
rm -f ~/.ssh/known_hosts # remove all fingerprints for a user

# Squid proxy
sudo vi /etc/squid/squid.conf # then add
acl facebook dstdomain .facebook.com # this
http_access deny facebook # and this

```

## 5 - Storage

```bash

```