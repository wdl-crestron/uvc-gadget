#! /bin/bash

modprobe libcomposite
#modprobe dummy_hcd

#echo 'file dummy_hcd.c +p' > /sys/kernel/debug/dynamic_debug/control

NAME=my_gadget
VID="0xFFFE"
PID="0xFFFD"
SERIAL="0123456789"
MANUFACTURER="Fake"
PRODUCT="FakeUVC"
UVC_FUNC="uvc.0"

BASE_PATH="/sys/kernel/config/usb_gadget"
DEV_PATH="$BASE_PATH/$NAME"

mkdir $DEV_PATH
echo $VID > $DEV_PATH/idVendor
echo $PID > $DEV_PATH/idProduct
echo "0x0300" > $DEV_PATH/bcdUSB
#echo "0xEF" > $DEV_PATH/bDeviceClass
#echo "0x2" > $DEV_PATH/bDeviceSubClass
#echo "0x1" > $DEV_PATH/bDeviceProtocol

mkdir -p $DEV_PATH/strings/0x409
echo $SERIAL > $DEV_PATH/strings/0x409/serialnumber
echo $MANUFACTURER > $DEV_PATH/strings/0x409/manufacturer
echo $PRODUCT > $DEV_PATH/strings/0x409/product

# UVC function
mkdir $DEV_PATH/functions/$UVC_FUNC

################################################################################
#mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/
#echo -en 'NV12\x0\x0\x10\x0\x80\x0\x0\xaa\x0\x38\x9b\x71'  > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/guidFormat
#mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/1080p
#
#echo 1080 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/1080p/wHeight
#echo 1920 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/1080p/wWidth
#
#cat << EOF > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/1080p/dwFrameInterval
#333333
#EOF
#
## 1920 * 1080 * 1.5 (4:2:0)
#echo 3110400 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/nv12/1080p/dwMaxVideoFrameBufferSize
#
################################################################################
mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/
#echo -en 'YUY2\x0\x0\x10\x0\x80\x0\x0\xaa\x0\x38\x9b\x71'  > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/guidFormat
mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/1080p

echo 1080 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/1080p/wHeight
echo 1920 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/1080p/wWidth

cat << EOF > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/1080p/dwFrameInterval
333333
EOF

# 1920 * 1080 * 2 (4:2:2)
echo 4147200 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/yuyv/1080p/dwMaxVideoFrameBufferSize
################################################################################
mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/mjpeg/m/1080p

cat << EOF > $DEV_PATH/functions/$UVC_FUNC/streaming/mjpeg/m/1080p/dwFrameInterval
333333
EOF

echo 1080 > $DEV_PATH/functions/$UVC_FUNC/streaming/mjpeg/m/1080p/wHeight
echo 1920 > $DEV_PATH/functions/$UVC_FUNC/streaming/mjpeg/m/1080p/wWidth

# 1920 * 1080
echo 2073600 > $DEV_PATH/functions/$UVC_FUNC/streaming/mjpeg/m/1080p/dwMaxVideoFrameBufferSize
################################################################################
# mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/
# # GUID
# # H264 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71
# echo -en 'H264\x0\x0\x10\x0\x80\x0\x0\xaa\x0\x38\x9b\x71'  > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/guidFormat
# echo 1 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/bVariableSize
# mkdir -p $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/1080p
# echo 0 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/1080p/dwBytesPerLine
# 
# cat << EOF > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/1080p/dwFrameInterval
# 333333
# 400000
# 666666
# 10000000
# EOF
# 
# echo 1080 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/1080p/wHeight
# echo 1920 > $DEV_PATH/functions/$UVC_FUNC/streaming/uncompressed/framebased/1080p/wWidth
################################################################################

mkdir $DEV_PATH/functions/$UVC_FUNC/streaming/header/h
pushd .
cd $DEV_PATH/functions/$UVC_FUNC/streaming/header/h
#ln -s ../../uncompressed/nv12
ln -s ../../uncompressed/yuyv
# ln -s ../../uncompressed/framebased
ln -s ../../mjpeg/m
cd ../../class/fs
ln -s ../../header/h
cd ../../class/hs
ln -s ../../header/h
cd ../../class/ss
ln -s ../../header/h

cd ../../../control
mkdir -p header/h
ln -s header/h class/fs
ln -s header/h class/ss
popd

echo 2048 > $DEV_PATH/functions/$UVC_FUNC/streaming_maxpacket

mkdir $DEV_PATH/configs/cfg.1
#mkdir $DEV_PATH/configs/cfg.1/strings/0x409
ln -s $DEV_PATH/functions/$UVC_FUNC $DEV_PATH/configs/cfg.1

UDC=`ls /sys/class/udc`
echo $UDC > /sys/kernel/config/usb_gadget/my_gadget/UDC
