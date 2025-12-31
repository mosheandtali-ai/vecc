/*
 * Scalar Vector Addition Example
 * 
 * This is a simple scalar implementation that adds two vectors element by element.
 * Each element is processed sequentially, one at a time.
 */

#include <stdio.h>
#include <stdlib.h>

#define VECTOR_SIZE 1024

void vector_add_scalar(const float* a, const float* b, float* c, int size) {
    for (int i = 0; i < size; i++) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    float *a = (float*)malloc(VECTOR_SIZE * sizeof(float));
    float *b = (float*)malloc(VECTOR_SIZE * sizeof(float));
    float *c = (float*)malloc(VECTOR_SIZE * sizeof(float));
    
    // Initialize input vectors
    for (int i = 0; i < VECTOR_SIZE; i++) {
        a[i] = (float)i;
        b[i] = (float)(i * 2);
    }
    
    // Perform scalar addition
    vector_add_scalar(a, b, c, VECTOR_SIZE);
    
    // Print first 10 results
    printf("First 10 results:\n");
    for (int i = 0; i < 10; i++) {
        printf("c[%d] = %.2f\n", i, c[i]);
    }
    
    free(a);
    free(b);
    free(c);
    
    return 0;
}
