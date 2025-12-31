# Scalar to OpenCL Conversion Guide for Synopsys EV72 Vector DSP

## Overview

This document explains how to convert scalar C/C++ code to OpenCL code optimized for the Synopsys EV72 vector DSP. The EV72 is part of the ARC EV7x Embedded Vision Processor family and features two enhanced vector processing units (VPUs) with 512-bit wide SIMD engines.

## Architecture Overview

### Synopsys EV72 Key Features:
- **Two 512-bit Vector Processing Units (VPUs)**
- Support for 8-bit, 16-bit, and 32-bit operations
- SIMD and VLIW execution capabilities
- OpenCL C support via MetaWare EV Development Toolkit
- Dedicated DNN acceleration hardware
- Optimized for computer vision and AI workloads

## Conversion Process

### Step 1: Identify Parallelizable Code

Look for loops and operations that can be executed in parallel:
- Element-wise array operations
- Independent iterations
- Data-parallel algorithms

### Step 2: Understand Memory Hierarchy

OpenCL memory types and their EV72 mapping:

| OpenCL Memory Type | Description | EV72 Mapping |
|-------------------|-------------|--------------|
| `__global` | Device main memory | External DRAM |
| `__local` | Work group shared memory | Fast local memory |
| `__constant` | Read-only memory | Optimized constant cache |
| `__private` | Per-work-item memory | Registers |

### Step 3: Write the OpenCL Kernel

Convert the parallel portion of your scalar code to an OpenCL kernel:

**Scalar Code:**
```c
void vector_add(float* a, float* b, float* c, int size) {
    for (int i = 0; i < size; i++) {
        c[i] = a[i] + b[i];
    }
}
```

**OpenCL Kernel:**
```opencl
__kernel void vector_add(__global const float* a,
                         __global const float* b,
                         __global float* c,
                         const int size)
{
    int i = get_global_id(0);
    if (i < size) {
        c[i] = a[i] + b[i];
    }
}
```

### Step 4: Optimize for EV72

#### Use Vector Data Types
The EV72 can process multiple values simultaneously. Use vector types:

```opencl
// Instead of processing one element at a time
float value = input[i];

// Process multiple elements
float4 value = vload4(i, input);  // Loads 4 floats
```

#### Coalesce Memory Accesses
Ensure adjacent work items access adjacent memory locations:

```opencl
// Good: Coalesced access
data[get_global_id(0)] = ...;

// Bad: Non-coalesced access
data[get_global_id(0) * stride] = ...;
```

#### Use Local Memory for Data Reuse
When multiple work items need the same data:

```opencl
__kernel void optimized(__global float* data,
                        __local float* cache,
                        ...)
{
    int lid = get_local_id(0);
    
    // Cooperative loading into local memory
    cache[lid] = data[get_global_id(0)];
    barrier(CLK_LOCAL_MEM_FENCE);
    
    // Use cached data
    float value = cache[lid];
}
```

#### Leverage Constant Memory
For filter coefficients and lookup tables:

```opencl
__constant float filter[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};

__kernel void convolve(__global float* input, ...) {
    // Compiler optimizes constant access
    float coeff = filter[i];
}
```

## Example Conversions

### 1. Vector Addition
- **Scalar:** `examples/scalar/vector_add.c`
- **OpenCL:** `examples/opencl/vector_add.cl`
- **Host:** `examples/opencl/vector_add_host.c`

Simple element-wise operation demonstrating basic kernel structure.

### 2. Image Convolution
- **Scalar:** `examples/scalar/image_convolution.c`
- **OpenCL:** `examples/opencl/image_convolution.cl`

2D operation showing how to handle multi-dimensional data and use constant memory.

### 3. FIR Filter
- **Scalar:** `examples/scalar/fir_filter.c`
- **OpenCL:** `examples/opencl/fir_filter.cl`

DSP-specific operation with data reuse patterns and local memory optimization.

### 4. Matrix Multiplication
- **Scalar:** `examples/scalar/matrix_multiply.c`
- **OpenCL:** `examples/opencl/matrix_multiply.cl`

Advanced example showing basic, tiled, and EV72-optimized implementations.

## EV72-Specific Optimization Techniques

### 1. Work Group Size Tuning
The EV72 performs best with specific work group sizes:

```c
// Recommended work group sizes for EV72
size_t local_work_size = 64;  // or 128, 256
size_t global_work_size = ((N + local_work_size - 1) / local_work_size) * local_work_size;
```

### 2. Vectorization Hints
The MetaWare compiler supports automatic vectorization. Help it by:

- Using vector types (float2, float4, float8, float16)
- Unrolling loops manually when beneficial
- Aligning data to vector boundaries

### 3. Memory Access Patterns
Optimize for the EV72's memory subsystem:

```opencl
// Aligned loads for better performance
__attribute__((aligned(64))) float data[1024];

// Sequential access patterns
for (int i = 0; i < size; i++) {
    output[i] = process(input[i]);  // Good
}
```

### 4. Instruction-Level Parallelism
The EV72 supports VLIW execution. Structure code to expose ILP:

```opencl
// Good: Independent operations can execute in parallel
float a = input1[i];
float b = input2[i];
float c = input3[i];
float d = input4[i];
output[i] = (a + b) * (c + d);
```

## Performance Tips

1. **Minimize Global Memory Access**: Use local memory for frequently accessed data
2. **Avoid Divergent Branches**: Minimize if-else conditions within kernels
3. **Use Built-in Functions**: OpenCL built-ins are optimized for EV72
4. **Profile and Iterate**: Use MetaWare profiling tools to identify bottlenecks

## Compilation

To compile for EV72 using MetaWare:

```bash
# Compile OpenCL kernel
mwccac -cl-std=CL1.2 -O3 kernel.cl

# Compile host code
mwccac -O3 -lOpenCL host.c -o app
```

## Common Patterns

### Pattern 1: Map Operation
Scalar loop → Single work item kernel

### Pattern 2: Reduction
Requires tree-based reduction in OpenCL with work group cooperation

### Pattern 3: Scan (Prefix Sum)
Use work group local memory and multiple kernel passes

### Pattern 4: Stencil Operations
Use local memory caching of neighborhood data

## Debugging

1. Start with CPU-based OpenCL for correctness
2. Add bounds checking in kernels during development
3. Use MetaWare simulator for EV72-specific testing
4. Compare results against scalar reference implementation

## Further Resources

- Synopsys MetaWare EV Development Toolkit Documentation
- OpenCL 1.2 Specification
- EV72 Processor Specification
- ARC EV7x Vision Processors Datasheet

## Summary

Converting scalar code to OpenCL for the EV72 involves:
1. Identifying parallel operations
2. Writing OpenCL kernels with appropriate memory qualifiers
3. Optimizing memory access patterns
4. Leveraging EV72's vector capabilities through vector types
5. Tuning work group sizes and memory usage
6. Using MetaWare tools for compilation and optimization

The examples in this repository demonstrate these principles with common DSP operations.
