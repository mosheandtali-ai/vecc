# Quick Reference: Scalar to OpenCL Conversion

## Basic Template

### Scalar Function
```c
void process(float* input, float* output, int size) {
    for (int i = 0; i < size; i++) {
        output[i] = computation(input[i]);
    }
}
```

### OpenCL Kernel
```opencl
__kernel void process(__global float* input, 
                      __global float* output,
                      int size) {
    int i = get_global_id(0);
    if (i < size) {
        output[i] = computation(input[i]);
    }
}
```

## Common Patterns

### 1D Data Processing
```opencl
int gid = get_global_id(0);
if (gid < size) {
    output[gid] = input[gid] * 2.0f;
}
```

### 2D Data Processing
```opencl
int x = get_global_id(0);
int y = get_global_id(1);
if (x < width && y < height) {
    int idx = y * width + x;
    output[idx] = input[idx];
}
```

### Using Local Memory
```opencl
__kernel void process(__global float* input,
                      __local float* cache) {
    int gid = get_global_id(0);
    int lid = get_local_id(0);
    
    // Load to local memory
    cache[lid] = input[gid];
    barrier(CLK_LOCAL_MEM_FENCE);
    
    // Use cached data
    float value = cache[lid];
}
```

## Memory Qualifiers

| Qualifier | Scope | Access | Speed | Use Case |
|-----------|-------|--------|-------|----------|
| `__global` | All work items | Read/Write | Slow | Large arrays |
| `__local` | Work group | Read/Write | Fast | Shared data |
| `__constant` | All work items | Read-only | Fast | Filter coefficients |
| `__private` | Single work item | Read/Write | Fastest | Temporary variables |

## Built-in Functions

### Work Item Functions
- `get_global_id(dim)` - Global work item ID
- `get_local_id(dim)` - Local work item ID within work group
- `get_group_id(dim)` - Work group ID
- `get_global_size(dim)` - Total number of work items
- `get_local_size(dim)` - Work group size

### Synchronization
- `barrier(CLK_LOCAL_MEM_FENCE)` - Synchronize local memory
- `barrier(CLK_GLOBAL_MEM_FENCE)` - Synchronize global memory

### Math Functions
- `sin()`, `cos()`, `tan()`, `sqrt()`, `exp()`, `log()`
- `fabs()`, `floor()`, `ceil()`, `round()`
- `fmin()`, `fmax()`, `clamp()`

### Vector Operations
- `dot(a, b)` - Dot product
- `length(v)` - Vector length
- `normalize(v)` - Normalize vector

## Vector Types (EV72 Optimized)

```opencl
float2 v2 = (float2)(1.0f, 2.0f);
float4 v4 = (float4)(1.0f, 2.0f, 3.0f, 4.0f);
float8 v8 = (float8)(1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f);
float16 v16; // 16 floats - optimal for EV72

// Access components
float x = v4.x; // or v4.s0
float y = v4.y; // or v4.s1
```

## Optimization Checklist

- [ ] Use appropriate memory qualifiers
- [ ] Minimize global memory access
- [ ] Coalesce memory accesses
- [ ] Use vector types where possible
- [ ] Avoid divergent branches
- [ ] Tune work group size
- [ ] Use local memory for data reuse
- [ ] Unroll small loops
- [ ] Use built-in functions
- [ ] Align data structures

## Common Pitfalls

1. **Not checking bounds**: Always validate `gid < size`
2. **Wrong memory qualifier**: Use `__global` for device memory
3. **Missing barriers**: Synchronize before using shared data
4. **Integer division**: Use float division for better performance
5. **Unaligned access**: Align data to vector boundaries

## EV72-Specific Tips

1. **Vector Width**: Use `float16` for optimal 512-bit SIMD usage
2. **Work Group Size**: Try 64, 128, or 256 for best performance
3. **Local Memory**: Leverage for frequently accessed data
4. **Constant Memory**: Use for filter kernels and lookup tables
5. **Loop Unrolling**: Helps compiler generate better vector code

## Example: Optimizing for EV72

### Before
```opencl
__kernel void simple(__global float* data) {
    int i = get_global_id(0);
    data[i] = data[i] * 2.0f;
}
```

### After
```opencl
__kernel void optimized(__global float* data) {
    int i = get_global_id(0);
    
    // Use vector load/store
    float4 v = vload4(i, data);
    v = v * 2.0f;
    vstore4(v, i, data);
}
```

## Debugging Steps

1. Verify kernel compiles without errors
2. Check host code properly transfers data
3. Compare with scalar implementation results
4. Print intermediate values (on CPU OpenCL)
5. Use smaller data sizes for testing
6. Profile with MetaWare tools on EV72

## Further Reading

- OpenCL C Specification: https://www.khronos.org/opencl/
- EV72 Documentation: Contact Synopsys
- This repo's CONVERSION_GUIDE.md for detailed examples
