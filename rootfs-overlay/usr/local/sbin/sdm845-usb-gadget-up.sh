#!/bin/bash

UDC=$(ls /sys/class/udc 2>/dev/null | head -1)
if [ -z "$UDC" ]; then
    echo "No UDC available"
    exit 0
fi

mount -t configfs none /sys/kernel/config 2>/dev/null || true
G=/sys/kernel/config/usb_gadget/g1

if [ ! -d "$G" ]; then
    mkdir -p $G/strings/0x409
    mkdir -p $G/configs/c.1/strings/0x409
    mkdir -p $G/functions/ncm.usb0

    echo 0x1d6b > $G/idVendor
    echo 0x0104 > $G/idProduct
    echo "Samsung Galaxy SDM845" > $G/strings/0x409/product
    echo "Samsung" > $G/strings/0x409/manufacturer
    echo "0123456789" > $G/strings/0x409/serialnumber
    echo "NCM USB Ethernet" > $G/configs/c.1/strings/0x409/configuration

    echo "42:69:69:69:42:01" > $G/functions/ncm.usb0/host_addr 2>/dev/null || true
    echo "42:69:69:69:42:02" > $G/functions/ncm.usb0/dev_addr 2>/dev/null || true
    [ -e "$G/configs/c.1/ncm.usb0" ] || ln -s "$G/functions/ncm.usb0" "$G/configs/c.1/" 2>/dev/null || true
    echo "$UDC" > $G/UDC 2>/dev/null || true
fi

sleep 1
ip link set usb0 up 2>/dev/null || true
ip addr add 172.16.42.1/24 dev usb0 2>/dev/null || true
echo "USB gadget active on 172.16.42.1"
