# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 ImmortalWrt.org
#
# ============ 本地源码模式（默认） ============
# 本仓库内置完整 C 源码（src/ 为源码树、CMakeLists.txt 与 src/ 同级，
# 与上游 stackia/rtp2httpd 源码包结构一致），已应用 010-session-end-log.patch。
# Build/Prepare 将 src/ 与 CMakeLists.txt 复制为构建目录，无需从上游下载源码包。
# 克隆整个仓库目录放入 feeds 后即可直接编译：
#   ./scripts/feeds update -i && ./scripts/feeds install rtp2httpd
#   make package/rtp2httpd/compile V=s
#
# 【切换为上游下载模式】（跟随上游 stackia/rtp2httpd 发布）：
#   1. 删除本仓库 src/ 目录与 CMakeLists.txt
#   2. 删除下方空的 define Build/Patch 与 define Build/Prepare
#   3. 取消注释 PKG_SOURCE / PKG_SOURCE_URL / PKG_HASH 三行
#   之后 010-session-end-log.patch 会由构建系统自动应用。

include $(TOPDIR)/rules.mk

PKG_NAME:=rtp2httpd
PKG_VERSION:=3.17.2
PKG_RELEASE:=1

# --- 上游下载模式（默认关闭；本地模式请保持注释）---
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/stackia/rtp2httpd/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=ce866091321a0d69dff7e8f7dda5d68be94e901659ed7d2ff4896029c8200ee6

PKG_MAINTAINER:=Tianling Shen <cnsztl@immrotalwrt.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# 本地模式：复制 src/（源码树）+ 根目录 CMakeLists.txt 到构建目录
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(CURDIR)/src $(PKG_BUILD_DIR)/
	cp $(CURDIR)/CMakeLists.txt $(PKG_BUILD_DIR)/
	cp $(CURDIR)/LICENSE $(PKG_BUILD_DIR)/
	cp $(CURDIR)/rtp2httpd.conf $(PKG_BUILD_DIR)/
endef

# 本地模式：010-session-end-log.patch 已合入 src/，跳过 patch 应用
define Build/Patch
endef

define Package/rtp2httpd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Multicast RTP/RTSP to Unicast HTTP stream converter
  URL:=https://rtp2httpd.com/en/
endef

define Package/rtp2httpd/description
  rtp2httpd converts RTP/UDP/RTSP media into http stream.
  It acts as a tiny HTTP server. When client connect,
  pre-configured multicast RTP service is choosen by URL.
  Program then join pre-configured multicast address and translate
  incoming RTP data to HTTP stream.
endef

define Package/rtp2httpd/conffiles
/etc/config/rtp2httpd
endef

CMAKE_OPTIONS += -DENABLE_AGGRESSIVE_OPT=ON

export RELEASE_VERSION=$(PKG_VERSION)

define Package/rtp2httpd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rtp2httpd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/rtp2httpd.config $(1)/etc/config/rtp2httpd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/rtp2httpd.init $(1)/etc/init.d/rtp2httpd
endef

$(eval $(call BuildPackage,rtp2httpd))
