#
# Copyright (C) 2013-2018 STMicroelectronics
# Denis Ciocca - Motion MEMS Product Div.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#/

ifneq ($(TARGET_SIMULATOR),true)

.PHONY: sensors-defconfig sensors-menuconfig sensors-cleanconf configfile

CURRENT_DIRECTORY := $(call my-dir)

include $(CLEAR_VARS)

MAJOR_VERSION := $(shell echo $(PLATFORM_VERSION) | cut -f1 -d.)
MINOR_VERSION := $(shell echo $(PLATFORM_VERSION) | cut -f2 -d.)

VERSION_KK := $(shell test $(MAJOR_VERSION) -eq 4 -a $(MINOR_VERSION) -eq 4 && echo true)
VERSION_L := $(shell test $(MAJOR_VERSION) -eq 5 && echo true)
VERSION_M := $(shell test $(MAJOR_VERSION) -eq 6 && echo true)
VERSION_N := $(shell test $(MAJOR_VERSION) -eq 7 && echo true)
VERSION_O := $(shell test $(MAJOR_VERSION) -eq 8 && echo true)
VERSION_P := $(shell test $(MAJOR_VERSION) -eq 9 && echo true)
VERSION_Q := $(shell test $(MAJOR_VERSION) -eq 10 && echo true)
VERSION_R := $(shell test $(MAJOR_VERSION) -eq 11 && echo true)

ifeq ($(VERSION_KK),true)
ST_HAL_ANDROID_VERSION := 0
DEFCONFIG := android_KK_defconfig
endif # VERSION_KK
ifeq ($(VERSION_L),true)
ST_HAL_ANDROID_VERSION := 1
DEFCONFIG := android_L_defconfig
endif # VERSION_L
ifeq ($(VERSION_M),true)
ST_HAL_ANDROID_VERSION := 2
DEFCONFIG := android_M_defconfig
endif # VERSION_M
ifeq ($(VERSION_N),true)
ST_HAL_ANDROID_VERSION := 3
DEFCONFIG := android_N_defconfig
endif # VERSION_N
ifeq ($(VERSION_O),true)
ST_HAL_ANDROID_VERSION := 4
DEFCONFIG := android_O_defconfig
endif # VERSION_O
ifeq ($(VERSION_P),true)
ST_HAL_ANDROID_VERSION := 5
DEFCONFIG := android_P_defconfig
endif # VERSION_P
ifeq ($(VERSION_Q),true)
ST_HAL_ANDROID_VERSION := 6
DEFCONFIG := android_Q_defconfig
endif # VERSION_Q
ifeq ($(VERSION_R),true)
ST_HAL_ANDROID_VERSION := 7
DEFCONFIG := android_R_defconfig
endif # VERSION_R

ANDROID_VERSION_CONFIG_HAL=$(CURRENT_DIRECTORY)/android_data_config
KCONFIG_CONFIG_HAL=$(CURRENT_DIRECTORY)/hal_config

$(shell rm $(ANDROID_VERSION_CONFIG_HAL))
$(shell echo 'export DEFCONFIG=$(DEFCONFIG)' > $(ANDROID_VERSION_CONFIG_HAL))
$(shell echo 'export ST_HAL_ANDROID_VERSION=$(ST_HAL_ANDROID_VERSION)' >> $(ANDROID_VERSION_CONFIG_HAL))

define \n

endef

define \space
//////////////////////////////////////////////////////////////////
endef

configfile:
	$(if $(wildcard $(KCONFIG_CONFIG_HAL)), , $(warning ${\n}${\n}${\space}${\n}defconfig file not found. Used default one: `$(DEFCONFIG)`.${\n}${\space}${\n}) @$(MAKE) sensors-defconfig > NULL)

sensors-defconfig:
	$(shell cp $(CURRENT_DIRECTORY)/src/$(DEFCONFIG) $(KCONFIG_CONFIG_HAL))
	$(CURRENT_DIRECTORY)/tools/mkconfig $(CURRENT_DIRECTORY)/ > $(CURRENT_DIRECTORY)/configuration.h

sensors-menuconfig: configfile
	$(CURRENT_DIRECTORY)/tools/kconfig-mconf $(CURRENT_DIRECTORY)/Kconfig
	$(CURRENT_DIRECTORY)/tools/mkconfig $(CURRENT_DIRECTORY)/ > $(CURRENT_DIRECTORY)/configuration.h

sensors-cleanconf:
	$(if $(wildcard $(KCONFIG_CONFIG_HAL)), rm $(KCONFIG_CONFIG_HAL), )
	$(if $(wildcard $(KCONFIG_CONFIG_HAL).old), rm $(KCONFIG_CONFIG_HAL).old, )
	$(if $(wildcard $(CURRENT_DIRECTORY)/configuration.h), rm $(CURRENT_DIRECTORY)/configuration.h, )

ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS := all_modules
endif

ifeq ($(filter sensors-defconfig sensors-menuconfig sensors-cleanconf,$(MAKECMDGOALS)),)
ifeq ("$(wildcard $(KCONFIG_CONFIG_HAL))","")
$(warning ${\n}${\n}${\space}${\n}defconfig file not found. Used default one: `$(DEFCONFIG)`.${\n}${\space}${\n})
$(shell cp $(CURRENT_DIRECTORY)/src/$(DEFCONFIG) $(KCONFIG_CONFIG_HAL))
$(shell $(CURRENT_DIRECTORY)/tools/mkconfig $(CURRENT_DIRECTORY)/ > $(CURRENT_DIRECTORY)/configuration.h)
endif # KCONFIG_CONFIG_HAL
include $(call all-makefiles-under, $(CURRENT_DIRECTORY))
endif # filter

endif # !TARGET_SIMULATOR