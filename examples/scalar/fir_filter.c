/*
 * Scalar FIR (Finite Impulse Response) Filter Example
 * 
 * This is a common DSP operation that applies a filter to a signal.
 * Each output sample is computed sequentially.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SIGNAL_SIZE 4096
#define FILTER_SIZE 64

void fir_filter_scalar(const float* input, const float* coeffs, 
                       float* output, int signal_size, int filter_size) {
    for (int i = 0; i < signal_size; i++) {
        float sum = 0.0f;
        
        for (int j = 0; j < filter_size; j++) {
            if (i >= j) {
                sum += input[i - j] * coeffs[j];
            }
        }
        
        output[i] = sum;
    }
}

int main() {
    float *input = (float*)malloc(SIGNAL_SIZE * sizeof(float));
    float *coeffs = (float*)malloc(FILTER_SIZE * sizeof(float));
    float *output = (float*)calloc(SIGNAL_SIZE, sizeof(float));
    
    // Initialize input signal (sine wave)
    for (int i = 0; i < SIGNAL_SIZE; i++) {
        input[i] = sinf(2.0f * M_PI * i / 100.0f);
    }
    
    // Initialize filter coefficients (simple low-pass)
    float sum_coeffs = 0.0f;
    for (int i = 0; i < FILTER_SIZE; i++) {
        coeffs[i] = expf(-0.1f * i);
        sum_coeffs += coeffs[i];
    }
    // Normalize coefficients
    for (int i = 0; i < FILTER_SIZE; i++) {
        coeffs[i] /= sum_coeffs;
    }
    
    // Apply FIR filter
    fir_filter_scalar(input, coeffs, output, SIGNAL_SIZE, FILTER_SIZE);
    
    printf("FIR filtering completed for signal size %d\n", SIGNAL_SIZE);
    printf("Sample output: %.4f, %.4f, %.4f\n", 
           output[100], output[200], output[300]);
    
    free(input);
    free(coeffs);
    free(output);
    
    return 0;
}
