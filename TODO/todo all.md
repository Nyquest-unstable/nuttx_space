我来为你设计一个完整的AI语音助手开发路线图。首先用mermaid绘制整体架构和工作流程。

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe', 'primaryTextColor': '#01579b', 'primaryBorderColor': '#0288d1', 'lineColor': '#0288d1', 'secondaryColor': '#fff3e0', 'tertiaryColor': '#e8f5e9'}}}%%

flowchart TB
    subgraph HW["硬件层 ESP32-S3-BOX-Lite"]
        MIC["双麦克风\nES7243 ADC"]
        SPK["扬声器\nES8156 DAC + NS4150 PA"]
        LCD["2.4寸LCD\nST7789V 240x320"]
        BTN["按键\nBOOT/RST/ADC"]
        IMU["6轴IMU\nICM-42670 (NC)"]
    end

    subgraph DRV["NuttX驱动层"]
        I2S_DRV["I2S驱动\n音频DMA"]
        I2C_DRV["I2C驱动\n配置接口"]
        SPI_DRV["SPI驱动\nLCD显示"]
        GPIO_DRV["GPIO驱动\n按键中断"]
        CODEC_DRV["Codec驱动\nES7243/ES8156"]
    end

    subgraph MID["中间件层"]
        AUDIO_PIPE["音频管道\n捕获/播放/混音"]
        VAD["语音活动检测\nVAD引擎"]
        AEC["回声消除\nAEC/NS"]
        OPUS["Opus编解码\n压缩传输"]
        WEBSOCKET["WebSocket客户端\n实时通信"]
        JSON["JSON解析\n协议处理"]
    end

    subgraph APP["应用层 - 小智AI助手"]
        WAKE["唤醒词检测\n本地/云端"]
        REC["录音管理\n连续识别"]
        CLOUD["云端对话\n大模型API"]
        TTS["语音合成\n流式播放"]
        GUI["UI界面\n状态显示"]
        CTRL["控制逻辑\n状态机"]
    end

    subgraph CLOUD_SVC["云端服务"]
        ASR["语音识别\nASR API"]
        LLM["大模型\nDeepSeek/ChatGPT"]
        TTS_SVC["语音合成\nTTS API"]
    end

    %% 硬件到驱动
    MIC -->|"I2S数据"| I2S_DRV
    SPK <--|"I2S数据"| I2S_DRV
    LCD -->|"SPI命令"| SPI_DRV
    BTN -->|"GPIO中断"| GPIO_DRV
    I2C_DRV -->|"配置"| MIC
    I2C_DRV -->|"配置"| SPK

    %% 驱动到中间件
    I2S_DRV -->|"PCM数据"| AUDIO_PIPE
    CODEC_DRV -->|"初始化"| I2S_DRV
    AUDIO_PIPE -->|"音频流"| VAD
    AUDIO_PIPE -->|"播放缓冲"| OPUS
    VAD -->|"触发事件"| REC
    OPUS <-->|"压缩数据"| WEBSOCKET

    %% 中间件到应用
    WEBSOCKET -->|"JSON-RPC"| JSON
    JSON -->|"指令"| CTRL
    REC -->|"上传音频"| WEBSOCKET
    CTRL -->|"状态更新"| GUI
    CTRL -->|"请求TTS"| TTS
    CTRL <-->|"对话"| CLOUD

    %% 应用到云端
    CLOUD <-->|"WebSocket"| CLOUD_SVC
    ASR -->|"文本"| LLM
    LLM -->|"回复"| TTS_SVC

    %% UI反馈
    GUI -->|"显示"| LCD
    BTN -->|"控制"| CTRL

    style HW fill:#ffebee
    style DRV fill:#e3f2fd
    style MID fill:#e8f5e9
    style APP fill:#fff3e0
    style CLOUD_SVC fill:#f3e5f5
```

```mermaid
%%{init: {'theme': 'base'}}%%

flowchart LR
    subgraph PHASE1["Phase 1: 底层驱动"]
        P1_1["I2C驱动验证"]
        P1_2["Codec驱动\nES7243/ES8156"]
        P1_3["I2S DMA驱动"]
        P1_4["LCD SPI驱动"]
        P1_5["GPIO按键驱动"]
    end

    subgraph PHASE2["Phase 2: 音频子系统"]
        P2_1["音频管道框架"]
        P2_2["录音引擎"]
        P2_3["播放引擎"]
        P2_4["Opus编解码"]
        P2_5["VAD集成"]
    end

    subgraph PHASE3["Phase 3: 网络与协议"]
        P3_1["WiFi连接管理"]
        P3_2["WebSocket客户端"]
        P3_3["JSON-RPC协议"]
        P3_4["云端对接"]
    end

    subgraph PHASE4["Phase 4: 应用集成"]
        P4_1["唤醒词检测"]
        P4_2["对话状态机"]
        P4_3["UI界面"]
        P4_4["小智协议适配"]
        P4_5["系统调优"]
    end

    PHASE1 --> PHASE2 --> PHASE3 --> PHASE4
    
    style PHASE1 fill:#ffebee
    style PHASE2 fill:#e3f2fd
    style PHASE3 fill:#e8f5e9
    style PHASE4 fill:#fff3e0
```

---

# ESP32-S3-BOX-Lite AI语音助手开发 TODO清单

## 小智AI助手方案 - NuttX RTOS实现

---

## Phase 1: 底层硬件驱动 (Week 1-2)

### 1.1 I2C总线驱动验证
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

### 1.2 Codec芯片驱动 (ES7243 + ES8156)
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

### 1.3 I2S DMA驱动
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

### 1.4 LCD显示驱动 (ST7789V)
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

- [ ] **LVGL集成** (可选)
  - 配置`CONFIG_LVGL`
  - 移植显示驱动
  - 添加触摸支持 (如有)

### 1.5 按键驱动
- [ ] **GPIO按键**
  - GPIO0: BOOT键 (内部上拉)
  - GPIO4: RST键 (通过复位芯片)
  - 配置为中断触发 (下降沿)

- [ ] **ADC按键** (扩展)
  - GPIO1: ADC1_CH0
  - 实现电压分压检测
  - 支持多按键识别

- [ ] **按键事件框架**
  - 短按/长按/双击检测
  - 发布按键事件到消息队列

---

## Phase 2: 音频子系统构建 (Week 3-4)

### 2.1 音频管道框架
- [ ] **音频缓冲区管理**
  ```c
  typedef struct {
      uint8_t *buffer;
      size_t size;
      size_t read_ptr;
      size_t write_ptr;
      sem_t sem;
  } audio_pipe_t;
  ```
  
- [ ] **录音管道**
  - 从I2S读取PCM数据
  - 环形缓冲设计 (建议4-8秒缓冲)
  - 支持 overrun 处理

- [ ] **播放管道**
  - 向I2S写入PCM数据
  - 欠载保护 (underrun)
  - 音量调节

### 2.2 录音引擎
- [ ] **连续录音模式**
  - 启动/停止控制
  - 音频数据回调
  - 支持多客户端订阅

- [ ] **音频格式转换**
  - 32bit → 16bit (右移16位)
  - 立体声 → 单声道 (可选)
  - 重采样 (48k→16k如有需要)

### 2.3 播放引擎
- [ ] **音频解码器接口**
  - 支持PCM直接播放
  - 预留Opus解码接口
  
- [ ] **播放队列管理**
  - 支持打断/混音
  - 优先级控制 (提示音 vs TTS)

### 2.4 Opus编解码集成
- [ ] **移植Opus库**
  - 配置`CONFIG_OPUS`
  - 优化内存使用 (减少RAM占用)
  
- [ ] **编码器配置**
  ```c
  // 语音识别优化参数
  - 采样率: 16kHz
  - 帧大小: 20ms (320 samples)
  - 码率: 16-24kbps
  - 复杂度: 3 (低延迟)
  - 应用: OPUS_APPLICATION_VOIP
  ```

- [ ] **解码器配置**
  - 支持流式解码
  - 错误恢复 (FEC)

### 2.5 VAD (语音活动检测)
- [ ] **集成WebRTC VAD**
  - 或轻量级VAD算法
  - 16kHz, 10ms/20ms帧
  
- [ ] **VAD事件触发**
  - 语音开始检测
  - 语音结束检测 (超时)
  - 触发录音上传

---

## Phase 3: 网络与通信协议 (Week 5-6)

### 3.1 WiFi连接管理
- [ ] **NuttX WiFi配置**
  - 启用`CONFIG_ESP32S3_WIFI`
  - 配置STA模式
  
- [ ] **网络管理器**
  - 自动重连机制
  - 连接状态事件
  - 信号强度监控

### 3.2 WebSocket客户端
- [ ] **移植WebSocket库**
  - 使用`libwebsockets`或自研
  - 支持wss (TLS加密)
  
- [ ] **连接管理**
  - 自动重连
  - 心跳保活 (ping/pong)
  - 连接状态回调

### 3.3 小智通信协议
- [ ] **JSON-RPC协议实现**
  ```json
  // 上行: 音频数据
  {
    "type": "audio",
    "session_id": "uuid",
    "data": "base64(opus_encoded)",
    "seq": 1
  }
  
  // 下行: 识别结果
  {
    "type": "asr_result",
    "text": "你好小智",
    "is_final": true
  }
  
  // 下行: TTS数据
  {
    "type": "tts",
    "data": "base64(opus_audio)",
    "is_final": false
  }
  ```

- [ ] **会话管理**
  - session_id生成
  - 对话上下文维护
  - 错误处理

### 3.4 云端服务对接
- [ ] **配置服务端点**
  - WebSocket URL
  - API密钥管理
  - 设备认证
  
- [ ] **协议适配层**
  - 小智协议封装
  - 大模型参数配置
  - 流式响应处理

---

## Phase 4: 应用层集成 (Week 7-8)

### 4.1 唤醒词检测
- [ ] **方案选择**
  - 方案A: 本地唤醒 (Snowboy/Porcupine)
  - 方案B: 云端VAD+关键词 (小智方案)
  
- [ ] **本地唤醒实现** (如选A)
  - 移植唤醒词引擎
  - 低功耗监听模式
  - 唤醒后全功能启动

### 4.2 对话状态机
```
状态定义:
├── IDLE (空闲)
├── LISTENING (监听中) - VAD触发
├── THINKING (处理中) - 上传云端
├── SPEAKING (播放中) - TTS输出
└── ERROR (错误恢复)
```

- [ ] **状态转换实现**
  - 事件驱动架构
  - 超时处理
  - 打断逻辑 (按键打断)

### 4.3 UI界面开发
- [ ] **显示状态设计**
  - 待机界面: 时间/天气/提示
  - 聆听界面: 波形动画
  - 思考界面: 加载动画
  - 说话界面: 机器人形象
  
- [ ] **LVGL界面实现**
  - 屏幕布局 (240x320)
  - 动画效果
  - 状态同步

### 4.4 小智协议完整适配
- [ ] **功能对接**
  - 连续对话支持
  - 上下文记忆
  - 技能调用 (IoT控制)
  
- [ ] **音频优化**
  - AEC回声消除 (防止自激)
  - 噪声抑制 (NS)
  - 自动增益 (AGC)

### 4.5 系统调优
- [ ] **性能优化**
  - CPU占用监控
  - 内存使用优化 (PSRAM 8MB)
  - 延迟优化 (端到端<500ms)
  
- [ ] **稳定性测试**
  - 长时间运行测试
  - 网络抖动处理
  - 异常恢复机制

---

## Phase 5: 部署与测试 (Week 9)

### 5.1 固件构建
- [ ] **NuttX配置汇总**
  ```bash
  # 关键配置选项
  CONFIG_ESP32S3_WROOM_1=y
  CONFIG_ESP32S3_I2C0=y
  CONFIG_ESP32S3_I2S=y
  CONFIG_ESP32S3_SPI2=y  # LCD
  CONFIG_ESP32S3_WIFI=y
  CONFIG_AUDIO=y
  CONFIG_OPUS=y
  CONFIG_NETUTILS_WEBSOCKET=y
  CONFIG_LVGL=y
  ```

- [ ] **分区表配置**
  ```
  # 16MB Flash分配
  nvs:      0x9000   (20KB)
  otadata:  0x2000   (8KB)
  app0:     0x200000 (2MB)  - NuttX固件
  app1:     0x200000 (2MB)  - OTA备份
  spiffs:   0x800000 (8MB)  - 资源文件
  coredump: 0x10000  (64KB)
  ```

### 5.2 测试验证
- [ ] **单元测试**
  - 各驱动独立测试
  - 音频质量测试 (THD+N)
  
- [ ] **集成测试**
  - 端到端延迟测试
  - 语音识别准确率
  - 对话流畅度

- [ ] **压力测试**
  - 24小时连续运行
  - 网络切换测试
  - 内存泄漏检测

---

## 关键代码结构建议

```
nuttx/
├── drivers/
│   ├── audio/
│   │   ├── es7243.c          # ADC驱动
│   │   ├── es8156.c          # DAC驱动
│   │   └── esp32s3_i2s.c     # I2S底层
│   └── lcd/
│       └── st7789v.c         # LCD驱动
├── apps/
│   └── xiaozhi_ai/
│       ├── main.c            # 应用入口
│       ├── audio/
│       │   ├── pipeline.c    # 音频管道
│       │   ├── recorder.c    # 录音引擎
│       │   ├── player.c      # 播放引擎
│       │   └── opus_codec.c  # Opus编解码
│       ├── network/
│       │   ├── websocket.c   # WS客户端
│       │   └── xiaozhi_proto.c # 小智协议
│       ├── ui/
│       │   ├── display.c     # 显示管理
│       │   └── lvgl_port.c   # LVGL移植
│       └── core/
│           ├── state_machine.c # 状态机
│           ├── session.c     # 会话管理
│           └── event_bus.c   # 事件总线
└── boards/
    └── esp32s3-box-lite/
        └── src/
            └── board_bringup.c # 板级初始化
```

---

## 风险与注意事项

| 风险点 | 解决方案 |
|:---|:---|
| I2S时钟抖动 | 使用专用PLL，MCLK由ESP32-S3 I2S外设生成 |
| 音频延迟 | 优化DMA缓冲区大小，建议20-40ms |
| Opus性能 | 启用ESP32-S3的向量指令加速，或降低复杂度 |
| 内存不足 | 使用8MB PSRAM，Opus分配在PSRAM |
| 网络不稳定 | 实现本地缓存，支持离线提示音 |
| 回声自激 | 必须实现AEC或硬件上避免扬声器对着麦克风 |

---

这个TODO清单涵盖了从底层驱动到上层应用的完整开发路径，预计8-9周完成MVP版本。建议按Phase迭代开发，每个Phase结束时进行集成测试。