#!/bin/bash

# Move to directory to use relative paths (1 syscall)
cd /sys/class/power_supply/BAT0/

# Read values directly into variables (2 syscalls)
read -r c_raw < current_now
read -r v_raw < voltage_now

# Integer math for Voltage (2 decimals)
v_scaled=$(( v_raw / 10000 ))
voltage="$(( v_scaled / 100 )).$(( v_scaled % 100 ))"

# Integer math for Wattage (2 decimals)
# Divide by 10^10 to keep two digits for the decimal part
w_scaled=$(( (c_raw * v_raw) / 10000000000 ))
w_decimal=$(( w_scaled % 100 ))

# Zero-pad the decimal manually to avoid a printf syscall
[[ ${#w_decimal} -eq 1 ]] && w_decimal="0$w_decimal"
#wattage="$(( w_scaled / 100 )).$w_decimal"
wattage="$(( w_scaled / 100 ))"

echo "${wattage}"

