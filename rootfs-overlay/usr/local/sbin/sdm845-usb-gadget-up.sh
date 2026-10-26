#!/bin/bash
set -e

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

    ln -sf $G/functions/ncm.usb0 $G/configs/c.1/
    echo "$UDC" > $G/UDC
fi

ip link set usb0 up || true
ip addr add 172.16.42.1/24 dev usb0 2>/dev/null || true
echo "USB gadget active on 172.16.42.1"
