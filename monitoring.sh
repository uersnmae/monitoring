arch=$(uname -a)
cpu=$(lscpu | grep "Socket(s)" | awk '{print $2}')
vcpu=$(lscpu | grep "^CPU(s)" | awk '{print $2}')
memtotal=$(free -m | grep "Mem:" | awk '{print $2}')
memusage=$(free -m | grep "Mem:" | awk '{print $3}')
memrate=$(echo "scale=2; (${memusage} / ${memtotal}) * 100" | bc)
disktotal=$(df -h / | awk 'NR==2 {print $2}')
diskusage=$(df -h / | awk 'NR==2 {print $3}')
diskrate=$(df -h / | awk 'NR==2 {print $5}')
idle=$(top -bn1 | grep "Cpu(s)" | awk -F ',' '{print $4}' | awk '{print $1}')
cpuload=$(echo "scale=1; 100 - $idle" | bc)
lastboot=$(who -b | awk '{print $3, $4}')
lvm=$(lvscan | awk '{print $1}' | grep -c -v "^ACTIVE")
connections=$(ss -t | wc -l)
tcp=$(echo "$connections - 1" | bc)
user=$(who | grep "pts" | wc -l)
ip=$(ifconfig | grep "inet " | awk 'NR==1 {print $2}')
eth=$(ifconfig | grep "ether" | awk 'NR==1 {print $2}')
cmd=$(find /var/log/sudo/ -type f -not -name "seq" | wc -l)
# 각 라인을 개별적으로 wall에 전달
{
  echo "#Architecture: $arch"
  echo -e "\t#CPU physical : $cpu"
  echo -e "\t#vCPU : $vcpu"
  echo -e "\t#Memory Usage: $memusage/${memtotal}MB (${memrate}%)"
  echo -e "\t#Disk Usage: ${diskusage}/${disktotal}b (${diskrate})"
  echo -e "\t#CPU load: ${cpuload}%"
  echo -e "\t#Last boot: $lastboot"
  if [ "$lvm" -eq 0 ]; then
    echo -e "\t#LVM use: yes"
  else
    echo -e "\t#LVM use: no"
  fi
  echo -e "\t#Connections TCP : $tcp ESTABLISHED"
  echo -e "\t#User log: $user"
  echo -e "\t#Network: IP $ip ($eth)"
  echo -e "\t#Sudo : $cmd cmd"
} | wall
