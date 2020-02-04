DEVICE = STM32F205xB
FLASH  = 0x08000000

USE_ST_CMSIS = true
USE_ST_HAL = true
USE_RTOS = true

# STM32F205 specific
SERIES_CPU  = cortex-m3
SERIES_ARCH = armv7-m
SERIES_FOLDER = STM32F2xx
MAPPED_DEVICE = STM32F205xx

STM32CUBE_PATH   ?= ./$(MAPPED_DEVICE)
RTOS_PATH   ?= ./FreeRTOS/Source
LINKER_SCRIPT ?= ./$(MAPPED_DEVICE)/$(DEVICE).ld
DEVICE_STARTUP = ./$(MAPPED_DEVICE)/startup/$(MAPPED_DEVICE).s

TOOLCHAIN_PATH      = /usr/bin
TOOLCHAIN_SEPARATOR = /

# Standard values for project folders
BIN_FOLDER ?= ./bin
OBJ_FOLDER ?= ./obj
SRC_FOLDER ?= ./src
INC_FOLDER ?= ./inc

CC      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-gcc
CXX     = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-g++
LD      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-ld -v
AR      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-ar
AS      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-gcc
OBJCOPY = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-objcopy
OBJDUMP = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-objdump
SIZE    = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)arm-none-eabi-size

GCC_FLAGS ?=
GCC_FLAGS += -specs=nosys.specs
GCC_FLAGS += -ffreestanding
GCC_FLAGS += -fno-exceptions
GCC_FLAGS += -fno-unwind-tables
GCC_FLAGS += -Wall
GCC_FLAGS += -Wextra
GCC_FLAGS += -g
# Flags - Optimization Options
GCC_FLAGS += -ffunction-sections
GCC_FLAGS += -fdata-sections

# Flags - Preprocessor options
GCC_FLAGS += -D $(MAPPED_DEVICE)

# Flags - Assembler Options

# Flags - Linker Options
# GCC_FLAGS += -nostdlib
GCC_FLAGS += -Wl,-T$(LINKER_SCRIPT)

# Flags - Directory Options
GCC_FLAGS += -I./inc
GCC_FLAGS += -I./$(MAPPED_DEVICE)/startup

# Flags - Machine-dependant options
GCC_FLAGS += -mcpu=$(SERIES_CPU)
GCC_FLAGS += -march=$(SERIES_ARCH)
GCC_FLAGS += -mlittle-endian
GCC_FLAGS += -mthumb
GCC_FLAGS += -masm-syntax-unified

# Output files
ELF_FILE_NAME ?= stm32_executable.elf
BIN_FILE_NAME ?= stm32_bin_image.bin
OBJ_FILE_NAME ?= startup_$(MAPPED_DEVICE).o

ELF_FILE_PATH = $(BIN_FOLDER)/$(ELF_FILE_NAME)
BIN_FILE_PATH = $(BIN_FOLDER)/$(BIN_FILE_NAME)
OBJ_FILE_PATH = $(OBJ_FOLDER)/$(OBJ_FILE_NAME)

# Input files
SRC ?=
SRC += $(SRC_FOLDER)/*.c

# CMSIS
GCC_FLAGS += -D CALL_ARM_SYSTEM_INIT
GCC_FLAGS += -I./$(MAPPED_DEVICE)/CMSIS/ARM/inc
GCC_FLAGS += -I./$(MAPPED_DEVICE)/CMSIS/$(SERIES_FOLDER)/inc
SRC += ./$(MAPPED_DEVICE)/CMSIS/$(SERIES_FOLDER)/src/*.c

# HAL
GCC_FLAGS += -D USE_HAL_DRIVER
GCC_FLAGS += -I./$(MAPPED_DEVICE)/HAL/$(SERIES_FOLDER)/inc
HAL_SRC := $(shell find $(STM32CUBE_PATH)/HAL/$(SERIES_FOLDER)/src/*.c ! -name '*_template.c')
SRC += $(HAL_SRC)

# RTOS
GCC_FLAGS += -I$(RTOS_PATH)/include
GCC_FLAGS += -I$(RTOS_PATH)/portable/GCC/ARM_CM3_MPU
GCC_FLAGS += -I$(RTOS_PATH)/CMSIS_RTOS_V2
SRC += $(RTOS_PATH)/*.c
SRC += $(RTOS_PATH)/portable/Common/*.c
SRC += $(RTOS_PATH)/portable/GCC/ARM_CM3_MPU/*.c
SRC += $(RTOS_PATH)/portable/MemMang/heap_1.c
SRC += $(RTOS_PATH)/CMSIS_RTOS_V2/*.c

# Make all
all:$(BIN_FILE_PATH)

$(BIN_FILE_PATH): $(ELF_FILE_PATH)
	$(OBJCOPY) -O binary $^ $@

$(ELF_FILE_PATH): $(SRC) $(OBJ_FILE_PATH) | $(BIN_FOLDER)
	$(CC) $(GCC_FLAGS) $^ -o $@

$(OBJ_FILE_PATH): $(DEVICE_STARTUP) | $(OBJ_FOLDER)
	$(CC) $(GCC_FLAGS) $^ -c -o $@

$(BIN_FOLDER):
	mkdir $(BIN_FOLDER)

$(OBJ_FOLDER):
	mkdir $(OBJ_FOLDER)

# Make clean
clean:
	rm -f $(ELF_FILE_PATH)
	rm -f $(BIN_FILE_PATH)
	rm -f $(OBJ_FILE_PATH)

# Make flash
flash:
	st-flash write $(BIN_FOLDER)/$(BIN_FILE_NAME) $(FLASH)

.PHONY: all clean flash
