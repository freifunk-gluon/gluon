sysctl_set() {
  sed -i "/^${1//./\.}=/d" /etc/sysctl.conf 
  echo "${1}=$2" >> /etc/sysctl.conf
}
