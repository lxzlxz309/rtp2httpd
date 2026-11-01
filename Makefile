# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 ImmortalWrt.org
#
# ============ 本地源码模式（默认） ============
# 本仓库内置完整 C 源码（src/，已应用 010-session-end-log.patch），
# 克隆仓库放到 feeds 下即可直接编译，无需从上游下载源码包。
# 若需跟随上游发布（下载 tar.gz + 自动应用 patches/*.patch），
# 请删除下方 Build/Prepare 定义，并取消注释 PKG_SOURCE / PKG_SOURCE_URL / PKG_HASH。

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

# 本地源码模式：把仓库内置 src/ 复制为构建目录（跳过下载与 patch 应用）
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -r $(CURDIR)/src/. $(PKG_BUILD_DIR)/
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
