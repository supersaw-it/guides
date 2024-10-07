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

```