#!/bin/bash

# postgresql is abbreviated as psql

# check the status of the psql

systemctl status postgresql

# service is active and running, now only way to know what's the problem is actually try to exec the command given to test the correctness 
# sudo -u postgres psql -c "insert into persons(name) values ('jane smith');" -d dt
# but this says the server is not listening, now only way to know why is to check logs
# we can cat the syslog or use journalctl to see logs, Imma cat the syslog

cat /var/log/syslog # it might be syslog.1

# we can see there's some problem with /opt/pgdata but still not clear about what is the excat problem, let's actually cat the psql logs, usually service logs are situated in /var/log/service_name/*

cat /var/log/postgresql/* # cat the latest log analyze what's the error

# 2024-02-25 05:34:44.542 UTC [659] FATAL:  could not create lock file "postmaster.pid": No space left on device
# seems like there's no space left for psql to store any new data, let's actually check what's the free storage left 

df -h 

# Filesystem       Size  Used Avail Use% Mounted on
# udev             224M     0  224M   0% /dev
# tmpfs             47M  1.5M   46M   4% /run
# /dev/nvme1n1p1   7.7G  1.2G  6.1G  17% /
# tmpfs            233M     0  233M   0% /dev/shm
# tmpfs            5.0M     0  5.0M   0% /run/lock
# tmpfs            233M     0  233M   0% /sys/fs/cgroup
# /dev/nvme1n1p15  124M  278K  124M   1% /boot/efi
# /dev/nvme0n1     8.0G  8.0G   28K 100% /opt/pgdata (we are only intrested in this, now we have 2 options can either extend storage by attaching external storage, this is not possible in sad servers, last option is to go and actually delete the existing data to free the storage)

ls /opt/pgdata
# deleteme  file1.bk  file2.bk  file3.bk  main (let's check which file is ultlizing most memory)

du -h /opt/pgdata/*.bk
# 7.0G    /opt/pgdata/file1.bk
# 923M    /opt/pgdata/file2.bk
# 488K    /opt/pgdata/file3.bk
# now we can delete all the bk files (actually you can delete file1.bk and proceed)

rm /opt/pgdata/*.bk

# now let's test of out psql db is accepting queries, 
sudo -u postgres psql -c "insert into persons(name) values ('jane smith');" -d dt
# psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: No such file or directory
# Is the server running locally and accepting connections on that socket?

# but we got a error again why, oh we forgot to restart the psql service; let's do it right away.

systemctl restart postgresql.service # no need to use sudo as we are logged as root

# now check again

# INSERT 0 1 (yaayy successfully solved)

