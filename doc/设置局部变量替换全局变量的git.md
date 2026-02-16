# 设置局部变量替换全局变量的git

## 问题描述

有时候，Git 的全局配置中会设置将 HTTPS 链接自动替换为 SSH 链接，这种配置可能会在克隆或拉取代码时引起问题，特别是在 NuttX 构建过程中。当Git全局配置中设置了将HTTPS替换为SSH的URL重写规则（如`url.git@github.com:.insteadof=https://github.com/`）时，可能导致NuttX构建过程中第三方HAL库的克隆失败，尤其是在未配置SSH密钥或网络限制SSH连接的情况下。

## 解决方案：在当前仓库设置局部配置覆盖全局配置

在不改变全局配置的前提下，我们可以在当前仓库（nuttx目录）中设置局部配置来覆盖全局的SSH替换规则。

## 详细步骤说明

### 步骤 1：进入 nuttx 目录

首先，切换到 nuttx 目录：

```bash
cd /home/zc/nuttx/nuttxspace/nuttx
```

### 步骤 2：设置局部配置覆盖全局配置

在 nuttx 目录中设置局部配置，以覆盖全局的 URL 替换规则：

```bash
git config --local url.git@github.com.insteadof ""
```

这个命令会在当前仓库的 `.git/config` 文件中添加一个配置项，它会优先于全局配置，确保在当前仓库中使用原始的 HTTPS 地址而不是替换为 SSH。

### 步骤 3：验证局部配置是否生效

验证局部配置是否正确设置：

```bash
git config --local --get-regexp "url\..*\.insteadof" || echo "No local url replacement configured"
```

如果配置成功，该命令将返回 `url.https://github.com/.insteadof`，表明本地配置已生效。

### 步骤 4：（可选）检查所有配置

检查当前仓库的所有 URL 相关配置：

```bash
git config --get-all url.https://github.com/.insteadof
```

## 如果远程仓库地址出现问题

如果你发现执行上述操作后，远程仓库地址变成了错误的格式（例如：`https://github.com/git@github.com:用户名/仓库.git`），请按以下步骤修复：

### 步骤 1：重置远程仓库地址

```bash
git remote set-url origin https://github.com/你的用户名/你的仓库名.git
```

或者，如果你想使用SSH格式：

```bash
git remote set-url origin git@github.com:你的用户名/你的仓库名.git
```

## 工作原理

Git 允许在不同级别上设置配置：

- 全局配置（`--global`）：影响当前用户的全部仓库
- 本地配置（`--local`）：仅影响当前仓库

本地配置会覆盖同名的全局配置。通过设置 `url.https://github.com/.insteadof ""`，我们将覆盖全局的 `url.git@github.com:.insteadof=https://github.com/` 规则，使 Git 在当前仓库中使用原始的 HTTPS 地址而不是替换为 SSH。

本地配置可以在  .git/config 文件中查看和修改。

## 注意事项

1. 这种本地配置只会影响当前目录下的 Git 仓库（nuttx目录），其他项目仍会使用全局设置。
2. 如果你需要恢复原来的全局配置行为，可以执行：
   ```bash
   git config --local --unset url.https://github.com/.insteadof
   ```
3. 这种方法特别适用于 NuttX 构建系统，因为它可以避免在克隆第三方 HAL 库时遇到 SSH 密钥问题，同时不影响其他项目的 Git 配置。