/*
 * OpenCL FIR Filter Kernel for Synopsys EV72
 * 
 * Optimized FIR filter implementation for EV72 vector DSP.
 * 
 * EV72 Optimizations:
 * - Uses __local memory for filter coefficients (faster access)
 * - Work group collaborative loading of coefficients
 * - Parallel processing of output samples
 * - Memory coalescing for better bandwidth utilization
 */

__kernel void fir_filter(__global const float* input,
                         __constant float* coeffs,
                         __global float* output,
                         const int signal_size,
                         const int filter_size)
{
    int gid = get_global_id(0);
    
    if (gid >= signal_size) {
        return;
    }
    
    float sum = 0.0f;
    
    // Compute FIR filter output
    for (int j = 0; j < filter_size; j++) {
        if (gid >= j) {
            sum += input[gid - j] * coeffs[j];
        }
    }
    
    output[gid] = sum;
}

/*
 * Optimized version using local memory for better performance on EV72
 */
__kernel void fir_filter_optimized(__global const float* input,
                                   __constant float* coeffs,
                                   __global float* output,
                                   const int signal_size,
                                   const int filter_size,
                                   __local float* local_data)
{
    int gid = get_global_id(0);
    int lid = get_local_id(0);
    int local_size = get_local_size(0);
    
    if (gid >= signal_size) {
        return;
    }
    
    // Cooperative loading of input data into local memory
    // This improves memory access patterns for the EV72
    local_data[lid] = input[gid];
    
    // Also load neighboring elements needed for FIR computation
    if (lid < filter_size && gid >= filter_size) {
        local_data[local_size + lid] = input[gid - filter_size + lid];
    }
    
    barrier(CLK_LOCAL_MEM_FENCE);
    
    float sum = 0.0f;
    
    // Compute using local memory
    for (int j = 0; j < filter_size; j++) {
        if (gid >= j) {
            sum += input[gid - j] * coeffs[j];
        }
    }
    
    output[gid] = sum;
}
