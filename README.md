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

## 使用方法（换环境克隆即编译）

### 1. 前提

- 已就绪的 OpenWrt / ImmortalWrt 编译环境（`./scripts/feeds update -a` 跑过一次，feeds 目录已初始化）。
- 编译工具链由 OpenWrt 构建系统自动提供（cmake / Ninja 会以 host 工具自动构建，无需手动安装）。
- 使用 SSH 方式克隆需已配置 GitHub SSH key；也可改用 HTTPS 地址。

### 2. 克隆到 feeds 的 packages 目录

```bash
# 方式一：直接克隆到目标位置（推荐）
git clone git@github.com:lxzlxz309/rtp2httpd.git <openwrt-src>/feeds/packages/net/rtp2httpd

# 方式二：先克隆到任意位置，再拷贝进 feeds
git clone git@github.com:lxzlxz309/rtp2httpd.git
cp -r rtp2httpd <openwrt-src>/feeds/packages/net/
```

> ⚠️ 若使用 ImmortalWrt：其 packages feed **自带** rtp2httpd 包，本仓库会**覆盖**该目录
> 以替换官方包；若使用官方 OpenWrt（packages feed 无此包），则纯属新增，无冲突。

### 3. 注册到 feeds

```bash
cd <openwrt-src>
./scripts/feeds update -i        # 只刷新 feed 索引，识别新放入的包
./scripts/feeds install rtp2httpd
```

### 4. 配置（menuconfig）

```bash
make menuconfig
# 进入 Network → rtp2httpd
#   按 Y：编入固件（固件里直接带）
#   按 M：编成独立安装包（推荐，产物为 .apk / .ipk）
```

> 只想单独出包、不改固件配置的，可以跳过 menuconfig，直接执行第 5 步。

### 5. 单独编译

```bash
make package/rtp2httpd/compile V=s
```

产物路径：

```
bin/packages/<目标架构>/packages/rtp2httpd-3.17.2-r1.apk
# 例：bin/packages/aarch64_cortex-a53/packages/rtp2httpd-3.17.2-r1.apk
```

（传统 ipk 固件则输出在 `bin/packages/<架构>/rtp2httpd_3.17.2-r1_<架构>.ipk`。）

### 6. 编入固件（可选）

在 menuconfig 中按 `Y` 选中后，直接整体编译：

```bash
make V=s        # 全量编译固件
```

## 构建模式说明

- **默认本地模式**：`Makefile` 中的 `Build/Prepare` 会把仓库内置的 `src/`（保留目录结构）、
  `CMakeLists.txt`、`LICENSE`、`rtp2httpd.conf` 组装为构建目录，**不访问上游网络、不下载、不重新打补丁**。
  已实测通过（make 4.3 / cmake + Ninja）。
- **跟随上游模式**：编辑 `Makefile`，删除 `Build/Prepare` / `Build/Patch` 定义并取消注释
  `PKG_SOURCE` / `PKG_SOURCE_URL` / `PKG_HASH` 三行即可（此时 `patches/*.patch` 自动应用）。

## 说明

- 本项目为自用定制版，基于 [stackia/rtp2httpd](https://github.com/stackia/rtp2httpd) v3.17.2。
- 配置项文档见 `docs/reference/configuration.md`；上游文档站点 https://rtp2httpd.com/。
