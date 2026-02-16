#!/bin/bash

# NuttX build script for ESP32-S3
# This script sets up the ESP-IDF environment and builds NuttX

echo "Setting up ESP-IDF environment..."

# 设置ESP-IDF路径
export IDF_PATH=/home/zc/ESP32-IDF/esp-idf

# 检查ESP-IDF是否存在
if [ ! -d "$IDF_PATH" ]; then
    echo "Error: ESP-IDF directory does not exist at $IDF_PATH"
    echo "Please update the IDF_PATH in this script."
    exit 1
fi

# 检查交叉编译器是否已经在PATH中可用（即是否已配置过）
if command -v xtensa-esp32s3-elf-gcc &> /dev/null; then
    echo "ESP-IDF toolchain is already configured."
    echo "Cross compiler found: $(which xtensa-esp32s3-elf-gcc)"
else
    echo "Activating ESP-IDF environment..."
    source $IDF_PATH/export.sh

    echo "ESP-IDF environment activated successfully."

    # 再次检查交叉编译器是否可用
    if ! command -v xtensa-esp32s3-elf-gcc &> /dev/null; then
        echo "Error: xtensa-esp32s3-elf-gcc is not available in PATH"
        echo "Please make sure ESP-IDF is properly installed and environment is set."
        exit 1
    fi

    echo "Cross compiler found: $(which xtensa-esp32s3-elf-gcc)"
fi

# 检查是否已经有 NuttX 配置（检查 .config 文件是否存在）
if [ -f ".config" ]; then
    echo "NuttX is already configured."
    SAVED_DEFCONFIG=$(grep "^CONFIG_DEFCONFIG_NAME=" .config | cut -d'=' -f2 | sed 's/"//g')
    if [ -n "$SAVED_DEFCONFIG" ]; then
        echo "Current configuration: $SAVED_DEFCONFIG"
    fi
    
    # 如果提供了参数，询问用户是否要更改配置
    if [ $# -gt 0 ]; then
        BOARD_CONFIG=$1
        echo "NuttX is already configured, but a configuration was provided: $BOARD_CONFIG"
        read -p "Do you want to reconfigure to $BOARD_CONFIG? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing existing configuration files..."
            
            # 删除所有配置文件
            rm -f .config .config.backup .config.old .config.orig
            
            echo "Existing configuration files removed."
            echo "Reconfiguring NuttX for: $BOARD_CONFIG"
            
            # 进入NuttX根目录（使用脚本所在目录的绝对路径）
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            cd "$SCRIPT_DIR"
            
            # 使用configure.sh脚本配置NuttX
            ./tools/configure.sh $BOARD_CONFIG
            
            # 更新保存的配置名称
            if [ -f ".config" ]; then
                SAVED_DEFCONFIG=$(grep "^CONFIG_DEFCONFIG_NAME=" .config | cut -d'=' -f2 | sed 's/"//g')
                echo "Successfully reconfigured to: $SAVED_DEFCONFIG"
            fi
        else
            echo "Keeping existing configuration."
        fi
    fi
else
    # 如果没有配置文件，根据参数配置NuttX
    if [ $# -gt 0 ]; then
        BOARD_CONFIG=$1
        echo "Configuring NuttX for: $BOARD_CONFIG"

        # 删除可能存在的配置文件
        rm -f .config .config.backup .config.old .config.orig

        # 进入NuttX根目录（使用脚本所在目录的绝对路径）
        SCRIPT_DIR="$(pwd)"
        cd "$SCRIPT_DIR"

        # 使用configure.sh脚本配置NuttX
        ./tools/configure.sh $BOARD_CONFIG
        
        echo "NuttX configured successfully."
    else
        # 默认配置为 esp32s3-box:zc-lite-feature
        BOARD_CONFIG="esp32s3-box:zc-lite-feature"
        echo "NuttX is not configured yet. Using default configuration: $BOARD_CONFIG"
        
        # 进入NuttX根目录（使用脚本所在目录的绝对路径）
        SCRIPT_DIR="$(pwd)"
        cd "$SCRIPT_DIR"
        ./tools/configure.sh $BOARD_CONFIG
        echo "NuttX configured successfully with $BOARD_CONFIG."
    fi
fi

echo "Environment setup completed. To build NuttX, run: make"