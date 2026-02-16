# Milestone 3: 网络与通信协议 (Week 5-6)

## 目标
实现WiFi连接管理和WebSocket通信，建立与云端服务的稳定连接。

---

## 3.1 WiFi连接管理
- [ ] **NuttX WiFi配置**
  - 启用`CONFIG_ESP32S3_WIFI`
  - 配置STA模式
  
- [ ] **网络管理器**
  - 自动重连机制
  - 连接状态事件
  - 信号强度监控

## 3.2 WebSocket客户端
- [ ] **移植WebSocket库**
  - 使用`libwebsockets`或自研
  - 支持wss (TLS加密)
  
- [ ] **连接管理**
  - 自动重连
  - 心跳保活 (ping/pong)
  - 连接状态回调

## 3.3 小智通信协议
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

## 3.4 云端服务对接
- [ ] **配置服务端点**
  - WebSocket URL
  - API密钥管理
  - 设备认证
  
- [ ] **协议适配层**
  - 小智协议封装
  - 大模型参数配置
  - 流式响应处理

## 成功标准
- [ ] WiFi能够自动连接并保持稳定
- [ ] WebSocket连接建立成功，心跳保活正常
- [ ] JSON-RPC协议解析和发送正常
- [ ] 与云端服务双向通信稳定
- [ ] 断线后能够自动重连