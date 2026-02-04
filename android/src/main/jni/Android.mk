ROOT := $(call my-dir)

# =======================
# Build libopus
# =======================

include $(CLEAR_VARS)
LOCAL_PATH       := $(ROOT)/libopus

#include the .mk files
include $(LOCAL_PATH)/celt_sources.mk
include $(LOCAL_PATH)/silk_sources.mk
include $(LOCAL_PATH)/opus_sources.mk

LOCAL_MODULE        := opus

#fixed point sources
SILK_SOURCES += $(SILK_SOURCES_FIXED)

#ARM build
CELT_SOURCES += $(CELT_SOURCES_ARM)
SILK_SOURCES += $(SILK_SOURCES_ARM)

#Include float support sources
OPUS_SOURCES += $(OPUS_SOURCES_FLOAT)

LOCAL_SRC_FILES     := \
$(CELT_SOURCES) $(SILK_SOURCES) $(OPUS_SOURCES)

LOCAL_LDLIBS        := -lm -llog

LOCAL_C_INCLUDES    := \
$(LOCAL_PATH)/include \
$(LOCAL_PATH)/silk \
$(LOCAL_PATH)/silk/fixed \
$(LOCAL_PATH)/celt

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_CFLAGS        := -DNULL=0 -DSOCKLEN_T=socklen_t -DLOCALE_NOT_USED -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64
LOCAL_CFLAGS       += -Drestrict='' -D__EMX__ -DOPUS_BUILD -DFIXED_POINT=1 -DUSE_ALLOCA -DHAVE_LRINT -DHAVE_LRINTF -O3 -fno-math-errno
LOCAL_CFLAGS       += -DNDEBUG
LOCAL_CFLAGS       += -O3

LOCAL_CPPFLAGS      := -DBSD=1
LOCAL_CPPFLAGS     += -ffast-math -O3 -funroll-loops

# ====== NEW: force 16KB page size ======
LOCAL_LDFLAGS      += -Wl,-z,max-page-size=16384

include $(BUILD_SHARED_LIBRARY)

# =======================
# Build libopusenc
# =======================

include $(CLEAR_VARS)
LOCAL_PATH       := $(ROOT)/libopusenc
LOCAL_MODULE      := opusenc

LOCAL_SRC_FILES := \
	$(addprefix ../, $(shell cd $(LOCAL_PATH)/../; find $(LOCAL_PATH)/src -type f -name '*.c'))

LOCAL_C_INCLUDES    := \
$(ROOT)/include \
$(LOCAL_PATH)/include

LOCAL_CFLAGS        := -DNULL=0 -DSOCKLEN_T=socklen_t -DLOCALE_NOT_USED -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64
LOCAL_CFLAGS       += -Drestrict='' -D__EMX__ -DOPUS_BUILD -DFIXED_POINT=1 -DUSE_ALLOCA -DHAVE_LRINT -DHAVE_LRINTF -O3 -fno-math-errno
LOCAL_CFLAGS       += -DNDEBUG
LOCAL_CFLAGS       += -O3

LOCAL_CFLAGS       += -DPACKAGE_NAME='"CHANGE THE PACKAGE NAME"'
LOCAL_CFLAGS       += -DPACKAGE_VERSION='"1.0.0"'
LOCAL_CFLAGS       += -DEXPORT=

LOCAL_CPPFLAGS      := -DBSD=1
LOCAL_CPPFLAGS     += -ffast-math -O3 -funroll-loops

LOCAL_STATIC_LIBRARIES := opus

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include

# ====== NEW: force 16KB page size ======
LOCAL_LDFLAGS      += -Wl,-z,max-page-size=16384

include $(BUILD_SHARED_LIBRARY)