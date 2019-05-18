export TARGET = iphone:latest:12.0
export ARCHS = arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Noire
$(TWEAK_NAME)_FILES = $(wildcard *.[xm])
$(TWEAK_NAME)_CFLAGS = -IHeaders

include $(THEOS_MAKE_PATH)/tweak.mk
