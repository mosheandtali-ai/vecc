/*
 * OpenCL Matrix Multiplication Kernels for Synopsys EV72
 * 
 * Multiple implementations showing progression from basic to optimized.
 */

/*
 * Basic kernel - Direct translation from scalar code
 * Each work item computes one element of the output matrix
 */
__kernel void matrix_multiply_basic(__global const float* A,
                                    __global const float* B,
                                    __global float* C,
                                    const int size)
{
    int i = get_global_id(0);  // Row
    int j = get_global_id(1);  // Column
    
    if (i >= size || j >= size) {
        return;
    }
    
    float sum = 0.0f;
    for (int k = 0; k < size; k++) {
        sum += A[i * size + k] * B[k * size + j];
    }
    
    C[i * size + j] = sum;
}

/*
 * Optimized kernel using local memory (work group tiles)
 * Better memory access patterns and reduced global memory traffic
 * Optimized for EV72's vector processing units
 */
#define TILE_SIZE 16

__kernel void matrix_multiply_tiled(__global const float* A,
                                    __global const float* B,
                                    __global float* C,
                                    const int size,
                                    __local float* A_tile,
                                    __local float* B_tile)
{
    int row = get_global_id(0);
    int col = get_global_id(1);
    int local_row = get_local_id(0);
    int local_col = get_local_id(1);
    
    float sum = 0.0f;
    
    // Loop over tiles
    int num_tiles = (size + TILE_SIZE - 1) / TILE_SIZE;
    for (int t = 0; t < num_tiles; t++) {
        // Load tile of A into local memory
        int a_row = row;
        int a_col = t * TILE_SIZE + local_col;
        if (a_row < size && a_col < size) {
            A_tile[local_row * TILE_SIZE + local_col] = A[a_row * size + a_col];
        } else {
            A_tile[local_row * TILE_SIZE + local_col] = 0.0f;
        }
        
        // Load tile of B into local memory
        int b_row = t * TILE_SIZE + local_row;
        int b_col = col;
        if (b_row < size && b_col < size) {
            B_tile[local_row * TILE_SIZE + local_col] = B[b_row * size + b_col];
        } else {
            B_tile[local_row * TILE_SIZE + local_col] = 0.0f;
        }
        
        // Synchronize to ensure tiles are loaded
        barrier(CLK_LOCAL_MEM_FENCE);
        
        // Compute partial dot product using tiles
        for (int k = 0; k < TILE_SIZE; k++) {
            sum += A_tile[local_row * TILE_SIZE + k] * B_tile[k * TILE_SIZE + local_col];
        }
        
        // Synchronize before loading next tile
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    
    // Write result
    if (row < size && col < size) {
        C[row * size + col] = sum;
    }
}

/*
 * EV72-specific optimized kernel
 * Uses vector types for better utilization of 512-bit SIMD units
 * The EV72 MetaWare compiler will map these to native vector instructions
 */
__kernel void matrix_multiply_ev72_optimized(__global const float* A,
                                             __global const float* B,
                                             __global float* C,
                                             const int size)
{
    int i = get_global_id(0);
    int j = get_global_id(1);
    
    if (i >= size || j >= size) {
        return;
    }
    
    // Process in groups of 4 for better vectorization
    // EV72 can handle up to 16 single-precision floats in parallel
    float4 sum = (float4)(0.0f, 0.0f, 0.0f, 0.0f);
    
    int k;
    for (k = 0; k <= size - 4; k += 4) {
        float4 a_vec = (float4)(A[i * size + k], 
                               A[i * size + k + 1],
                               A[i * size + k + 2],
                               A[i * size + k + 3]);
        float4 b_vec = (float4)(B[k * size + j],
                               B[(k + 1) * size + j],
                               B[(k + 2) * size + j],
                               B[(k + 3) * size + j]);
        sum += a_vec * b_vec;
    }
    
    // Handle remaining elements
    float final_sum = sum.x + sum.y + sum.z + sum.w;
    for (; k < size; k++) {
        final_sum += A[i * size + k] * B[k * size + j];
    }
    
    C[i * size + j] = final_sum;
}
