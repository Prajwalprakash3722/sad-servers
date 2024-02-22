sudo lsof | grep var/log/bad.log | awk '{ print $2}' | xargs kill -9
