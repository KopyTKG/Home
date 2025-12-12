# !/bin/bash

IP_ADDRESS="192.168.50."
for i in {1..4}
do
  echo "Powering on server at ${IP_ADDRESS}${i}..."
  ipmitool -H ${IP_ADDRESS}${i} -U ADMIN -P ADMIN power on
  sleep 2
done
echo "All servers powered on."
