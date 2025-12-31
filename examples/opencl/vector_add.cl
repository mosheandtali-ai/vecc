/*
 * OpenCL Vector Addition Kernel for Synopsys EV72 Vector DSP
 * 
 * This kernel performs vector addition optimized for the EV72's 512-bit SIMD vector engine.
 * The EV72 can process multiple elements in parallel using its vector processing units.
 *
 * Key optimizations for EV72:
 * - Uses __global memory pointers for efficient memory access
 * - Work items can be mapped to vector lanes for SIMD execution
 * - The EV72 MetaWare OpenCL compiler will automatically vectorize this kernel
 */

__kernel void vector_add(__global const float* a,
                         __global const float* b,
                         __global float* c,
                         const int size)
{
    // Get the global work item ID
    int gid = get_global_id(0);
    
    // Ensure we don't access beyond array bounds
    if (gid < size) {
        c[gid] = a[gid] + b[gid];
    }
}
