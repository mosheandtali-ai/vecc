# Makefile for VECC Examples
# Builds scalar and OpenCL examples

CC = gcc
CFLAGS = -O2 -Wall
LDFLAGS = -lm
OPENCL_LDFLAGS = -lOpenCL

# Directories
SCALAR_DIR = examples/scalar
OPENCL_DIR = examples/opencl
BUILD_DIR = build

# Scalar examples
SCALAR_SOURCES = $(wildcard $(SCALAR_DIR)/*.c)
SCALAR_BINS = $(patsubst $(SCALAR_DIR)/%.c,$(BUILD_DIR)/scalar_%,$(SCALAR_SOURCES))

# OpenCL host code
OPENCL_HOST_SOURCES = $(wildcard $(OPENCL_DIR)/*_host.c)
OPENCL_HOST_BINS = $(patsubst $(OPENCL_DIR)/%_host.c,$(BUILD_DIR)/opencl_%,$(OPENCL_HOST_SOURCES))

# Phony targets
.PHONY: all clean scalar opencl help

# Default target
all: scalar opencl

# Help target
help:
	@echo "VECC Examples Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build all examples (default)"
	@echo "  scalar     - Build scalar examples only"
	@echo "  opencl     - Build OpenCL examples only"
	@echo "  clean      - Remove all build artifacts"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples will be built in the '$(BUILD_DIR)' directory"
	@echo ""
	@echo "Scalar examples:"
	@echo "  - scalar_vector_add"
	@echo "  - scalar_image_convolution"
	@echo "  - scalar_fir_filter"
	@echo "  - scalar_matrix_multiply"
	@echo ""
	@echo "OpenCL examples:"
	@echo "  - opencl_vector_add"
	@echo ""
	@echo "Note: OpenCL examples require OpenCL runtime libraries"

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build scalar examples
scalar: $(BUILD_DIR) $(SCALAR_BINS)

$(BUILD_DIR)/scalar_%: $(SCALAR_DIR)/%.c
	@echo "Building scalar example: $@"
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

# Build OpenCL examples
opencl: $(BUILD_DIR) $(OPENCL_HOST_BINS)
	@echo "Copying OpenCL kernel files to build directory..."
	@cp $(OPENCL_DIR)/*.cl $(BUILD_DIR)/ 2>/dev/null || true

$(BUILD_DIR)/opencl_%: $(OPENCL_DIR)/%_host.c
	@echo "Building OpenCL example: $@"
	$(CC) $(CFLAGS) $< -o $@ $(OPENCL_LDFLAGS)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)

# Individual targets for convenience
.PHONY: vector_add image_conv fir_filter matrix_mult

vector_add: $(BUILD_DIR) $(BUILD_DIR)/scalar_vector_add $(BUILD_DIR)/opencl_vector_add
	@cp $(OPENCL_DIR)/vector_add.cl $(BUILD_DIR)/ 2>/dev/null || true

image_conv: $(BUILD_DIR) $(BUILD_DIR)/scalar_image_convolution

fir_filter: $(BUILD_DIR) $(BUILD_DIR)/scalar_fir_filter

matrix_mult: $(BUILD_DIR) $(BUILD_DIR)/scalar_matrix_multiply
