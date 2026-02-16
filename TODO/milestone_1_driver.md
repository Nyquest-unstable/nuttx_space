# Milestone 1: 底层硬件驱动开发 (Week 1-2)

## 目标
完成ESP32-S3-BOX-Lite的基础硬件驱动开发，为音频子系统奠定基础。

---

## 1.1 I2C总线驱动验证
- [ ] **配置NuttX I2C驱动**
  - 确认GPIO18(SCL)/GPIO8(SDA)引脚配置
  - 启用`CONFIG_ESP32S3_I2C0`
  - 设置I2C时钟频率400kHz
  
- [ ] **验证I2C设备扫描**
  - 扫描地址0x10 (ES8156)
  - 扫描地址0x20-0x27 (ES7243)
  - 编写`i2c_scan`测试工具

- [ ] **I2C调试工具**
  - 实现`i2cget`/`i2cset`命令
  - 添加寄存器dump功能

## 1.2 Codec芯片驱动 (ES7243 + ES8156)
- [ ] **ES7243 ADC驱动**
  ```c
  // 关键配置
  - I2S格式: I2S Philips, 24bit, MSB First
  - 采样率: 16kHz (语音识别优化)
  - MCLK: 256*Fs = 4.096MHz
  - 输入增益: 0dB
  ```
  - 编写`es7243.c`驱动文件
  - 实现初始化序列
  - 配置双麦克风输入
  
- [ ] **ES8156 DAC驱动**
  ```c
  // 关键配置
  - I2S格式: 与ADC同步
  - 输出模式: Differential (差分)
  - 音量控制: 0dB ~ -96dB
  - 静音控制: 通过PA_CTRL (GPIO46)
  ```
  - 编写`es8156.c`驱动文件
  - 实现DAC初始化
  - 添加音量控制API

- [ ] **Codec注册到NuttX音频框架**
  - 实现`audio_ops_s`接口
  - 注册为`/dev/audio/pcm0`

## 1.3 I2S DMA驱动
- [ ] **I2S控制器配置**
  - GPIO分配:
    - GPIO2: I2S_MCLK
    - GPIO17: I2S_SCLK
    - GPIO47: I2S_LRCK
    - GPIO16: I2S_ADC_SDOUT (RX)
    - GPIO15: I2S_DAC_SDIN (TX)
  - DMA通道: RX DMA_CH2, TX DMA_CH3
  
- [ ] **实现I2S DMA传输**
  - 环形缓冲区设计 (双缓冲)
  - 中断处理: DMA完成回调
  - 支持32 slot/sample (24bit有效)

- [ ] **音频时钟计算**
  ```
  目标: 16kHz, 32bit, 立体声
  BCLK = 16k * 32 * 2 = 1.024MHz
  MCLK = 256 * 16k = 4.096MHz (或384*16k=6.144MHz)
  ```

## 1.4 LCD显示驱动 (ST7789V)
- [ ] **SPI接口配置**
  - GPIO5: CS
  - GPIO6: MOSI (SDA)
  - GPIO7: SCK
  - GPIO4: DC (数据/命令)
  - GPIO48: RST
  - GPIO45: BL (背光，通过MOSFET)
  - SPI频率: 40MHz

- [ ] **ST7789V初始化序列**
  - 软件复位
  - 配置240x320分辨率
  - 设置色彩格式RGB565
  - 使能显示

- [ ] **Framebuffer驱动**
  - 实现`fb_vtable_s`接口
  - 双缓冲机制
  - 注册为`/dev/fb0`

## 1.5 按键驱动
- [ ] **GPIO按键**
  - GPIO0: BOOT键 (内部上拉)
  - GPIO4: RST键 (通过复位芯片)
  - 配置为中断触发 (下降沿)

- [ ] **按键事件框架**
  - 短按/长按/双击检测
  - 发布按键事件到消息队列

## 成功标准
- [ ] I2C能够成功扫描到ES7243和ES8156
- [ ] I2S能够正常接收和发送音频数据
- [ ] LCD能够正常显示图像
- [ ] 按键能够正确响应并触发事件
- [ ] 所有驱动在NuttX框架中正确注册