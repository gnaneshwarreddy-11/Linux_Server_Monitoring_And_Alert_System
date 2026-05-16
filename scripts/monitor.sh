#!/bin/bash

# =========================================================
# Project Name : SysWatch
# Description  : Linux Monitoring & Alert System
# Author       : Gnaneshwar Reddy
# Version      : 1.0
# =========================================================
#
# Features:
#   - CPU Usage Monitoring
#   - Memory Usage Monitoring
#   - Disk Usage Monitoring
#   - Network Connectivity Check
#   - System Uptime Tracking
#   - Alert Logging
#
# Technologies Used:
#   - Linux
#   - Bash Scripting
#   - Networking Commands
#
# Log Files:
#   - system.log  -> Stores normal monitoring logs
#   - alerts.log  -> Stores alert messages
#
# =========================================================


# Load configuration file
source ../config/thresholds.conf

# Log file paths
LOG_FILE="../logs/system.log"
ALERT_FILE="../alerts/alerts.log"

# Current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# =========================================================
# Function : log_message
# Purpose  : Store normal logs in system.log
# =========================================================

log_message() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}


# =========================================================
# Function : alert_message
# Purpose  : Store alert logs in alerts.log
# =========================================================

alert_message() {
    echo "[$TIMESTAMP] ALERT: $1" >> "$ALERT_FILE"
}


# =========================================================
# Function : check_cpu
# Purpose  : Monitor CPU usage
# =========================================================

check_cpu() {

    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)

    log_message "CPU Usage = ${CPU_USAGE}%"

    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        alert_message "High CPU Usage Detected (${CPU_USAGE}%)"
    fi
}

# =========================================================
# Function : check_memory
# Purpose  : Monitor memory usage
# =========================================================

check_memory() {

    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)

    log_message "Memory Usage = ${MEMORY_USAGE}%"

    if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        alert_message "High Memory Usage Detected (${MEMORY_USAGE}%)"
    fi
}

# =========================================================
# Function : check_disk
# Purpose  : Monitor disk usage
# =========================================================

check_disk() {

    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

    log_message "Disk Usage = ${DISK_USAGE}%"

    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        alert_message "High Disk Usage Detected (${DISK_USAGE}%)"
    fi
}

# =========================================================
# Function : check_network
# Purpose  : Check internet connectivity
# =========================================================

check_network() {

    if ping -c 1 $PING_TARGET > /dev/null 2>&1; then
        log_message "Network Status = UP"
    else
        log_message "Network Status = DOWN"
        alert_message "Network Connectivity Failure"
    fi
}

# =========================================================
# Function : check_uptime
# Purpose  : Monitor system uptime
# =========================================================

check_uptime() {

    SYSTEM_UPTIME=$(uptime -p)

    log_message "System Uptime = $SYSTEM_UPTIME"
}

# =========================================================
# Main Execution
# =========================================================

log_message "========== Server Monitoring Started =========="

check_cpu
check_memory
check_disk
check_network
check_uptime

log_message "========== Monitoring Completed =========="
