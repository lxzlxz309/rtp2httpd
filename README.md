# rtp2httpd（OpenWrt/ImmortalWrt 本地编译版）

Multicast RTP/RTSP 转 Unicast HTTP 流媒体转换器。
本仓库 = OpenWrt package 定义 + **完整 C 源码**（v3.17.2，含本地修改），
克隆后放入任何 OpenWrt / ImmortalWrt 环境的 feeds 即可直接编译。

> ✅ **已在 ImmortalWrt 25.x（aarch64_cortex-a53, musl）实测编译通过**，
> 产物 `rtp2httpd-3.17.2-r1.apk`。

## 与上游的差异

| 修改 | 说明 |
| --- | --- |
| `010-session-end-log.patch`（**已合入 `src/`**） | access_log 增加**会话结束日志行**（末列附会话开始时间戳，便于统计收视时长） |
| LuCI 界面修复 | TypedSection 实例类型 + openPage 通配 host，见独立仓库 [lxzlxz309/luci-app-rtp2httpd](https://github.com/lxzlxz309/luci-app-rtp2httpd) |

## 仓库结构

```
rtp2httpd/
├── Makefile          # OpenWrt 包定义（默认本地源码模式，免下载）
├── files/            # 安装到路由器的配置模板与 init 脚本
├── patches/          # 修改补丁（本地模式下已合入 src/，仅作修改记录）
├── src/              # 完整 C 源码（3.17.2 + 010 补丁已应用）
├── CMakeLists.txt    # 顶层 CMake 构建入口（与 src/ 同级，与上游源码包一致）
├── rtp2httpd.conf    # 示例配置文件（cmake install 需要）
├── LICENSE           # GPL-2.0-or-later
└── docs/             # 官方文档（配置参考）
```

## 快速编译（换环境克隆即编译）

```bash
git clone git@github.com:lxzlxz309/rtp2httpd.git
cp -r rtp2httpd <openwrt-src>/feeds/packages/net/
cd <openwrt-src>
./scripts/feeds update -i
./scripts/feeds install rtp2httpd
make package/rtp2httpd/compile V=s
```

- **默认本地模式**：`Makefile` 中的 `Build/Prepare` 会把仓库内置的 `src/`（保留目录结构）、
  `CMakeLists.txt`、`LICENSE`、`rtp2httpd.conf` 组装为构建目录，不访问上游网络、不下载、不重新打补丁。
  已实测通过（make 4.3 / cmake + Ninja）。
- **跟随上游模式**：编辑 `Makefile`，删除 `Build/Prepare` / `Build/Patch` 定义并取消注释
  `PKG_SOURCE` / `PKG_SOURCE_URL` / `PKG_HASH` 三行即可（此时 `patches/*.patch` 自动应用）。

## 说明

- 本项目为自用定制版，基于 [stackia/rtp2httpd](https://github.com/stackia/rtp2httpd) v3.17.2。
- 配置项文档见 `docs/reference/configuration.md`；上游文档站点 https://rtp2httpd.com/。
