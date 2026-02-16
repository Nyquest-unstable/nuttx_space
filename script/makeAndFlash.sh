#!/bin/bash

# NuttX编译和烧录脚本
# 该脚本执行make编译和flash烧录命令

# 默认串口端口
DEFAULT_PORT="/dev/ttyACM0"

# 检查是否有自定义端口参数传入
if [ $# -eq 0 ]; then
    PORT=$DEFAULT_PORT
else
    PORT=$1
fi

echo "开始编译并烧录NuttX..."
echo "使用串口端口: $PORT"

# 执行make命令，使用8个并行任务进行编译，然后烧录到设备
make -j8 flash ESPTOOL_PORT=$PORT ESPTOOL_BINDIR=./

if [ $? -eq 0 ]; then
    echo "编译和烧录成功完成！"
    echo "正在启动 picocom..."
    picocom -b 115200 $PORT
else
    echo "编译或烧录过程中出现错误！"
    exit 1
fi