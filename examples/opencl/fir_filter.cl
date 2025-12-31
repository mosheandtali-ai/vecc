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
 * Note: local_data size should be at least (local_size + filter_size - 1)
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
    int group_id = get_group_id(0);
    int group_start = group_id * local_size;
    
    // Cooperative loading of input data into local memory
    // Load main data
    if (gid < signal_size) {
        local_data[lid] = input[gid];
    } else {
        local_data[lid] = 0.0f;
    }
    
    // Load halo elements (history needed for FIR filter)
    if (lid < filter_size - 1) {
        int halo_idx = group_start - filter_size + 1 + lid;
        if (halo_idx >= 0 && halo_idx < signal_size) {
            local_data[local_size + lid] = input[halo_idx];
        } else {
            local_data[local_size + lid] = 0.0f;
        }
    }
    
    barrier(CLK_LOCAL_MEM_FENCE);
    
    if (gid >= signal_size) {
        return;
    }
    
    float sum = 0.0f;
    
    // Compute using local memory
    // Map global index to local memory access
    for (int j = 0; j < filter_size; j++) {
        if (gid >= j) {
            // Calculate offset in local memory
            int local_offset = lid - j;
            float value;
            if (local_offset >= 0) {
                // Data is in main local buffer
                value = local_data[local_offset];
            } else {
                // Data is in halo buffer
                value = local_data[local_size + filter_size - 1 + local_offset];
            }
            sum += value * coeffs[j];
        }
    }
    
    output[gid] = sum;
}
