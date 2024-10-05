## 1 - Essential commands

```bash
sed -i '500,2000 s/enabled/disabled/gi' values.conf # lines
sed -i 's~#%$2jh//238720//31223~$2//23872031223~g' /home/bob/data.txt # bs 

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

```

