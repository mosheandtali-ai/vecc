/*
 * Scalar Image Convolution (3x3 Filter) Example
 * 
 * This implements a simple 3x3 convolution filter in scalar code.
 * Each pixel is processed sequentially.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define IMAGE_WIDTH 512
#define IMAGE_HEIGHT 512

// Simple 3x3 edge detection filter (Sobel X)
const float filter[3][3] = {
    {-1.0f,  0.0f,  1.0f},
    {-2.0f,  0.0f,  2.0f},
    {-1.0f,  0.0f,  1.0f}
};

void convolve_scalar(const float* input, float* output, int width, int height) {
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            float sum = 0.0f;
            
            // Apply 3x3 filter
            for (int fy = -1; fy <= 1; fy++) {
                for (int fx = -1; fx <= 1; fx++) {
                    int pixel_idx = (y + fy) * width + (x + fx);
                    sum += input[pixel_idx] * filter[fy + 1][fx + 1];
                }
            }
            
            output[y * width + x] = sum;
        }
    }
}

int main() {
    int size = IMAGE_WIDTH * IMAGE_HEIGHT;
    float *input = (float*)malloc(size * sizeof(float));
    float *output = (float*)calloc(size, sizeof(float));
    
    // Initialize input image with sample data
    for (int i = 0; i < size; i++) {
        input[i] = (float)(i % 256);
    }
    
    // Perform convolution
    convolve_scalar(input, output, IMAGE_WIDTH, IMAGE_HEIGHT);
    
    printf("Convolution completed for %dx%d image\n", IMAGE_WIDTH, IMAGE_HEIGHT);
    printf("Sample output pixels: %.2f, %.2f, %.2f\n", 
           output[100], output[200], output[300]);
    
    free(input);
    free(output);
    
    return 0;
}
