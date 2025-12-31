# VECC - Vector Computing Examples for Synopsys EV72

This repository contains examples demonstrating how to convert scalar C code to OpenCL code optimized for the Synopsys EV72 vector DSP.

## Overview

The Synopsys EV72 is an embedded vision processor featuring two 512-bit vector processing units (VPUs) with SIMD capabilities. This repository provides:

- **Scalar implementations**: Traditional C code processing data sequentially
- **OpenCL implementations**: Parallel code optimized for EV72's vector architecture
- **Documentation**: Comprehensive guide on conversion strategies and optimization techniques

## Repository Structure

```
vecc/
├── examples/
│   ├── scalar/              # Scalar C implementations
│   │   ├── vector_add.c
│   │   ├── image_convolution.c
│   │   ├── fir_filter.c
│   │   └── matrix_multiply.c
│   └── opencl/              # OpenCL implementations for EV72
│       ├── vector_add.cl
│       ├── vector_add_host.c
│       ├── image_convolution.cl
│       ├── fir_filter.cl
│       └── matrix_multiply.cl
├── docs/
│   └── CONVERSION_GUIDE.md  # Detailed conversion guide
└── README.md
```

## Examples

### 1. Vector Addition
The simplest example showing basic scalar to OpenCL conversion.
- **Operation**: Element-wise addition of two arrays
- **Key Concepts**: Basic kernel structure, memory management, work items

### 2. Image Convolution (3x3 Filter)
Demonstrates 2D data processing with a Sobel edge detection filter.
- **Operation**: Apply 3x3 filter to each pixel
- **Key Concepts**: 2D work groups, constant memory for filters, boundary handling

### 3. FIR Filter
Common DSP operation for signal processing.
- **Operation**: Finite Impulse Response filtering
- **Key Concepts**: Data reuse, local memory optimization, sliding window

### 4. Matrix Multiplication
Advanced example with multiple optimization levels.
- **Operation**: Multiply two NxN matrices
- **Key Concepts**: Tiling, local memory, vector types, work group cooperation

## Quick Start

### Prerequisites

For actual EV72 hardware:
- Synopsys MetaWare EV Development Toolkit
- EV72 development board or simulator

For learning/development:
- Any OpenCL-capable device (CPU, GPU)
- OpenCL headers and libraries
- GCC or Clang compiler

### Building Scalar Examples

```bash
# Vector addition
gcc -O2 examples/scalar/vector_add.c -o vector_add -lm

# Image convolution
gcc -O2 examples/scalar/image_convolution.c -o image_conv -lm

# FIR filter
gcc -O2 examples/scalar/fir_filter.c -o fir_filter -lm

# Matrix multiplication
gcc -O2 examples/scalar/matrix_multiply.c -o matrix_mult -lm
```

### Building OpenCL Examples (Generic OpenCL)

```bash
# Ensure OpenCL is installed
# Ubuntu/Debian:
# sudo apt-get install opencl-headers ocl-icd-opencl-dev

# Build host code for vector addition
gcc -O2 examples/opencl/vector_add_host.c -o vector_add_opencl -lOpenCL

# Copy the kernel file to the same directory
cp examples/opencl/vector_add.cl .

# Run
./vector_add_opencl
```

### Building for Synopsys EV72

```bash
# Using MetaWare compiler
mwccac -O3 -cl-std=CL1.2 examples/opencl/vector_add.cl -o vector_add.ev72

# Compile host code
mwccac -O3 examples/opencl/vector_add_host.c -o vector_add_host -lOpenCL
```

## Understanding the Code

### Scalar Code Pattern
```c
void operation(float* input, float* output, int size) {
    for (int i = 0; i < size; i++) {
        output[i] = process(input[i]);  // Sequential processing
    }
}
```

### OpenCL Kernel Pattern
```opencl
__kernel void operation(__global float* input,
                        __global float* output,
                        int size) {
    int i = get_global_id(0);  // Parallel processing
    if (i < size) {
        output[i] = process(input[i]);
    }
}
```

## Key Differences: Scalar vs OpenCL

| Aspect | Scalar | OpenCL |
|--------|--------|--------|
| Execution | Sequential | Parallel |
| Loop Control | Manual `for` loops | Work items (threads) |
| Memory | Simple pointers | Explicit memory spaces |
| Optimization | Compiler auto-vectorization | Explicit SIMD operations |
| Code Structure | Single file | Kernel + Host code |

## EV72-Specific Features

The EV72 provides unique capabilities leveraged in these examples:

1. **512-bit SIMD Units**: Process 16 single-precision floats or 8 double-precision floats simultaneously
2. **Vector Data Types**: `float4`, `float8`, `float16` map efficiently to hardware
3. **Local Memory**: Fast scratchpad memory for work group data sharing
4. **DNN Accelerators**: Dedicated hardware for neural network operations
5. **MetaWare Compiler**: Advanced optimizations for EV72 architecture

## Performance Expectations

Typical speedups for EV72 OpenCL vs scalar C:

- **Vector Addition**: 8-16x (memory bandwidth limited)
- **Image Convolution**: 10-20x (compute bound)
- **FIR Filter**: 12-25x (data reuse benefits)
- **Matrix Multiply**: 15-40x (optimization dependent)

*Note: Actual performance depends on problem size, memory access patterns, and optimization level.*

## Learning Path

1. **Start with Vector Addition**: Understand basic kernel structure
2. **Try Image Convolution**: Learn 2D indexing and constant memory
3. **Implement FIR Filter**: Master data reuse and local memory
4. **Optimize Matrix Multiply**: Explore advanced tiling and vectorization

## Documentation

See [docs/CONVERSION_GUIDE.md](docs/CONVERSION_GUIDE.md) for:
- Detailed conversion strategies
- EV72 architecture overview
- Memory optimization techniques
- Common patterns and pitfalls
- Performance tuning guidelines

## Debugging Tips

1. **Verify Correctness First**: Run OpenCL on CPU/GPU before EV72
2. **Compare Results**: Check OpenCL output matches scalar reference
3. **Start Simple**: Begin with basic kernel, then optimize
4. **Use Profiling**: MetaWare tools help identify bottlenecks
5. **Check Bounds**: Add range checks during development

## Common Issues and Solutions

### Issue: Different results between scalar and OpenCL
- Check floating-point operation order
- Verify array bounds and indexing
- Compare intermediate values

### Issue: Poor performance
- Review memory access patterns (coalescing)
- Check work group size
- Verify local memory usage
- Use profiling tools

### Issue: Compilation errors
- Check OpenCL version compatibility (EV72 supports OpenCL 1.2)
- Verify memory qualifiers (`__global`, `__local`, etc.)
- Ensure kernel argument types match host code

## Contributing

This is an educational repository. Improvements welcome:
- Additional example algorithms
- Better optimization techniques
- Documentation enhancements
- Bug fixes

## References

- [Synopsys EV7x Vision Processors](https://www.synopsys.com/designware-ip/processor-solutions/ev-processors/ev7x-vision-processors.html)
- [MetaWare EV Development Toolkit](https://www.synopsys.com/designware-ip/processor-solutions/arc-metaware-ev.html)
- [OpenCL 1.2 Specification](https://www.khronos.org/registry/OpenCL/)
- [Heterogeneous Computing with OpenCL 2.0](https://www.elsevier.com/books/heterogeneous-computing-with-opencl-20/kaeli/978-0-12-801414-1)

## License

This repository is provided for educational purposes. Example code is free to use and modify.

## Support

For EV72-specific questions:
- Consult Synopsys MetaWare documentation
- Contact Synopsys support

For general OpenCL questions:
- [Khronos OpenCL Forums](https://community.khronos.org/c/opencl/)
- [Stack Overflow OpenCL tag](https://stackoverflow.com/questions/tagged/opencl)

---

**Note**: These examples are designed for learning and demonstration. Production code may require additional error handling, optimization, and validation.
