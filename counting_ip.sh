awk '{ print $1 }' access.log | sort | uniq -c | sort -rn | head -n 1 | awk '{ print $2 }' > highestip.txt
