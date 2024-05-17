uci -q batch <<-EOF >/dev/null
    set luci.main.mediaurlbase='/luci-static/bootstrap'
    add system led # =cfg068bba
    set system.@led[-1].name='5G Down'
    set system.@led[-1].sysfs='red:5g'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='wwan0'
    add system led # =cfg078bba
    set system.@led[-1].name='Signal'
    set system.@led[-1].sysfs='blue:signal'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='wwan0'
    add_list system.@led[-1].mode='link'
    add system led # =cfg088bba
    set system.@led[-1].name='Signal Down'
    set system.@led[-1].sysfs='red:signal'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='wwan0'
    add system led # =cfg098bba
    set system.@led[-1].name='Phone'
    set system.@led[-1].sysfs='green:phone'
    set system.@led[-1].trigger='default-on'
    add system led # =cfg0a8bba
    set system.@led[-1].name='Power'
    set system.@led[-1].sysfs='green:power'
    set system.@led[-1].trigger='default-on'
    add system led # =cfg0b8bba
    set system.@led[-1].name='Internet'
    set system.@led[-1].sysfs='green:internet'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='br-lan'
    add_list system.@led[-1].mode='link'
    add_list system.@led[-1].mode='tx'
    add_list system.@led[-1].mode='rx'
    add system led # =cfg0c8bba
    set system.@led[-1].name='Wi-Fi-5G'
    set system.@led[-1].sysfs='green:wifi'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='phy0-ap0'
    add_list system.@led[-1].mode='link'
    add_list system.@led[-1].mode='tx'
    add_list system.@led[-1].mode='rx'
    add system led # =cfg0d8bba
    set system.@led[-1].name='Wi-Fi'
    set system.@led[-1].sysfs='green:wifi'
    set system.@led[-1].trigger='netdev'
    set system.@led[-1].dev='phy1-ap0'
    add_list system.@led[-1].mode='link'
    add_list system.@led[-1].mode='tx'
    add_list system.@led[-1].mode='rx
    commit system
EOF

uci commit system

chmod +x /etc/openclash/core/clash_meta
mv /etc/openclash/core/speedtest /bin/
chmod +x /bin/speedtest

exit 0
