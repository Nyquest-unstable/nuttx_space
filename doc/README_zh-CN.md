<p align="center">
<img src="https://raw.githubusercontent.com/apache/nuttx/master/Documentation/_static/NuttX320.png" width="175">
</p>

![POSIX徽章](https://img.shields.io/badge/POSIX-兼容-brightgreen?style=flat&label=POSIX)
[![许可证](https://img.shields.io/badge/License-Apache%202.0-blue
)](https://nuttx.apache.org/docs/latest/introduction/licensing.html)
![问题跟踪徽章](https://img.shields.io/badge/issue_track-github-blue?style=flat&label=Issue%20Tracking)
[![贡献者](https://img.shields.io/github/contributors/apache/nuttx
)](https://github.com/apache/nuttx/graphs/contributors)
[![GitHub构建徽章](https://github.com/apache/nuttx/workflows/Build/badge.svg)](https://github.com/apache/nuttx/actions/workflows/build.yml)
[![文档徽章](https://github.com/apache/nuttx/workflows/Build%20Documentation/badge.svg)](https://nuttx.apache.org/docs/latest/index.html)

Apache NuttX 是一款注重标准兼容性和小内存占用的实时操作系统(RTOS)。
NuttX 支持从 8 位到 64 位的微控制器环境，其主要遵循的标准是 POSIX 和 ANSI 标准。
此外，还采用了来自 Unix 和其他常见 RTOS（如 VxWorks）的标准 API，
以支持这些标准下不可用的功能，或不适合深度嵌入式环境的功能（如 fork()）。

为简洁起见，文档许多部分会将 Apache NuttX 简称为 NuttX。

## 入门指南
第一次使用 NuttX？请阅读 [入门指南](https://nuttx.apache.org/docs/latest/quickstart/index.html)！
如果您没有可用的开发板，NuttX 有自己的模拟器，可以在终端中运行。

## 文档
您可以在 [文档页面](https://nuttx.apache.org/docs/latest/) 找到当前的 NuttX 文档。

或者，您可以按照文档构建 [说明](https://nuttx.apache.org/docs/latest/contributing/documentation.html) 自行构建文档。

旧的 NuttX 文档仍然可在 [Apache wiki](https://cwiki.apache.org/NUTTX/NuttX) 中找到。

## 支持的开发板
NuttX 支持各种平台。请参阅 [支持的平台页面](https://nuttx.apache.org/docs/latest/platforms/index.html) 查看完整列表。

## ESP32-S3 Box 特定配置

### zc-lite-feature 配置

zc-lite-feature 配置是一个针对 ESP32-S3 Box 开发板的特殊配置，位于 [configs/zc-lite-feature/defconfig](file:///home/zc/nuttx/nuttxspace/nuttx/tools/../arch/xtensa/configs/esp32s3-korvo-2/configs/audio/defconfig)。该配置结合了按钮功能和音频功能，使其适用于需要音频输入输出能力的应用场景。

#### 与 buttons 配置的主要区别：

1. **音频支持**：
   - zc-lite-feature 配置启用了完整的音频子系统 (CONFIG_AUDIO=y)
   - 包含 ES8311 音频编解码器驱动 (CONFIG_AUDIO_ES8311=y)
   - 配置了 I2S 接口用于音频数据传输 (CONFIG_AUDIO_I2S=y)

2. **I2S 和 I2C 配置**：
   - zc-lite-feature 配置了 I2S 接口引脚 (BCLK, DOUT, MCLK, WS)
   - 包含 I2C 接口配置，用于音频编解码器控制

3. **额外的音频缓冲区和内存管理**：
   - 配置了多个音频缓冲区 (CONFIG_AUDIO_NUM_BUFFERS=8)
   - 包含了更多内存管理和音频相关的配置选项

4. **保留按钮功能**：
   - 与 buttons 配置一样，zc-lite-feature 也保留了按钮输入功能 (CONFIG_EXAMPLES_BUTTONS=y)

### 如何应用 zc-lite-feature 配置

要应用 zc-lite-feature 配置，可以使用以下方法之一：

#### 方法一：使用 env.sh 脚本（推荐）

1. 确保你的 [env.sh](file:///home/zc/nuttx/nuttxspace/nuttx/env.sh) 脚本在 NuttX 项目根目录下
2. 运行以下命令：
   ```bash
   cd /home/zc/nuttx/nuttxspace/nuttx
   ./env.sh esp32s3-box:zc-lite-feature
   ```

该脚本会自动：
- 检查 ESP-IDF 环境是否已设置
- 验证交叉编译器是否可用
- 如果已有配置，会提示是否要切换到新配置
- 如果没有配置，会应用 esp32s3-box:zc-lite-feature 配置

#### 方法二：直接使用 configure.sh 脚本

```bash
cd /home/zc/nuttx/nuttxspace/nuttx
./tools/configure.sh esp32s3-box:zc-lite-feature
```

#### 方法三：使用 menuconfig 修改配置

如果已经配置了其他配置，可以通过 menuconfig 更改：
```bash
cd /home/zc/nuttx/nuttxspace/nuttx
make menuconfig
```
在配置菜单中选择 "esp32s3-box" 并启用 zc-lite-feature 相关选项。

配置完成后，可以使用以下命令编译：
```bash
make
```

## 贡献
如果您希望为 NuttX 项目做贡献，请阅读 [贡献指南](https://nuttx.apache.org/docs/latest/contributing/index.html)，了解有关 Git 使用、编码标准、工作流程和 NuttX 原则的信息。

## 许可证
此仓库中的代码采用 Apache 2 许可证，或与 Apache 2 许可证兼容的许可证发布。更多信息请参见 [许可证页面](https://nuttx.apache.org/docs/latest/introduction/licensing.html)。