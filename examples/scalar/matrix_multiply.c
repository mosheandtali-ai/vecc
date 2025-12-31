/*
 * Scalar Matrix Multiplication Example
 * 
 * Multiplies two matrices using traditional nested loops.
 * Each element is computed sequentially.
 */

#include <stdio.h>
#include <stdlib.h>

#define MATRIX_SIZE 128

void matrix_multiply_scalar(const float* A, const float* B, float* C, int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            float sum = 0.0f;
            for (int k = 0; k < size; k++) {
                sum += A[i * size + k] * B[k * size + j];
            }
            C[i * size + j] = sum;
        }
    }
}

int main() {
    int size = MATRIX_SIZE;
    int total_elements = size * size;
    
    float *A = (float*)malloc(total_elements * sizeof(float));
    float *B = (float*)malloc(total_elements * sizeof(float));
    float *C = (float*)calloc(total_elements, sizeof(float));
    
    // Initialize matrices
    for (int i = 0; i < total_elements; i++) {
        A[i] = (float)(i % 10);
        B[i] = (float)((i + 1) % 10);
    }
    
    // Perform matrix multiplication
    matrix_multiply_scalar(A, B, C, size);
    
    printf("Matrix multiplication completed for %dx%d matrices\n", size, size);
    printf("Sample results: C[0][0]=%.2f, C[1][1]=%.2f, C[2][2]=%.2f\n", 
           C[0], C[size + 1], C[2 * size + 2]);
    
    free(A);
    free(B);
    free(C);
    
    return 0;
}
