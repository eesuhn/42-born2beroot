#!/bin/bash

# Architecture
ARCH=$(uname -a)

# Physical processors
PCPU=$(grep -c "physical id" /proc/cpuinfo)

# Virtual processors
VCPU=$(grep -c "processor" /proc/cpuinfo)

# RAM
RAM_TOTAL=$(free --mega | awk '$1 == "Mem:" {print $2}')
RAM_USED=$(free --mega | awk '$1 == "Mem:" {print $3}')
RAM_PERCENT=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk
DISK_TOTAL=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
DISK_USED=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
DISK_PERCENT=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t += $2} END {printf("%d"), disk_u/disk_t*100}')

# CPU load
CPU=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
CPU_LOAD=$(printf "%.1f" $(expr 100 - $CPU))

# Last boot
BOOT=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVM
LVM_STATUS=$(if [ $(lsblk | grep -c "lvm") -gt 0 ]; then echo yes; else echo no; fi)

# TCP
TCP_CONNECTION=$(ss -ta | grep -c "ESTAB")

# User count
USER_LOGGED=$(users | wc -w)

# IP and MAC
IP=$(hostname -I)
MAC=$(ip link | grep "link/ether" | awk '{print $2}')

# Sudo
SUDO_CMND=$(journalctl _COMM=sudo | grep -c "COMMAND")

wall "  Architecture: $ARCH
		CPU physical: $PCPU
		vCPU: $VCPU
		Memory Usage: $RAM_USED/${RAM_TOTAL}MB ($RAM_PERCENT%)
		Disk Usage: $DISK_USED/${DISK_TOTAL} ($DISK_PERCENT%)
		CPU load: $CPU_LOAD%
		Last boot: $BOOT
		LVM use: $LVM_STATUS
		Connections TCP: $TCP_CONNECTION ESTABLISHED
		User log: $USER_LOGGED
		Network: IP $IP($MAC)
		Sudo: $SUDO_CMND cmd"
