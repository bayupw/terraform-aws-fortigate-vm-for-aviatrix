config system admin
    edit admin
        set password ${fw_admin_password}
end
config system global
    set hostname fg
    set timezone 04
end
config system interface
    edit port1
    set alias "WAN"
    next
    edit port2
    set alias "LAN"
    set allowaccess ping https
end
config router static
    edit 1
        set dst 10.0.0.0 255.0.0.0
        set gateway ${lan_gateway_ip}
        set device port2
    next
    edit 2
        set dst 172.16.0.0 255.240.0.0
        set gateway ${lan_gateway_ip}
        set device port2
    next
    edit 3
        set dst 192.168.0.0 255.255.0.0
        set gateway ${lan_gateway_ip}
        set device port2
    next
end
config firewall policy
    edit 1
        set name allow-all-LAN-to-WAN
        set srcintf port2
        set dstintf port1
        set action accept
        set srcaddr all
        set dstaddr all
        set schedule always
        set service ALL
        set logtraffic all
        set logtraffic-start enable
        set nat enable
    next
    edit 2
        set name allow-all-LAN-to-LAN
        set srcintf port2
        set dstintf port2
        set srcaddr all
        set dstaddr all
        set action accept
        set schedule always
        set service ALL
        set logtraffic all
        set logtraffic-start enable
    next
end