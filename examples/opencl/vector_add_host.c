/*
 * OpenCL Host Code for Vector Addition on Synopsys EV72
 * 
 * This host code sets up the OpenCL environment and executes the vector addition kernel.
 */

#include <stdio.h>
#include <stdlib.h>
#include <CL/cl.h>

#define VECTOR_SIZE 1024
#define MAX_SOURCE_SIZE (0x100000)

int main() {
    cl_platform_id platform_id = NULL;
    cl_device_id device_id = NULL;
    cl_context context = NULL;
    cl_command_queue command_queue = NULL;
    cl_mem a_mem_obj = NULL;
    cl_mem b_mem_obj = NULL;
    cl_mem c_mem_obj = NULL;
    cl_program program = NULL;
    cl_kernel kernel = NULL;
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret;
    
    float *a = (float*)malloc(VECTOR_SIZE * sizeof(float));
    float *b = (float*)malloc(VECTOR_SIZE * sizeof(float));
    float *c = (float*)malloc(VECTOR_SIZE * sizeof(float));
    
    // Initialize input vectors
    for (int i = 0; i < VECTOR_SIZE; i++) {
        a[i] = (float)i;
        b[i] = (float)(i * 2);
    }
    
    // Load kernel source code
    FILE *fp;
    char *source_str;
    size_t source_size;
    
    fp = fopen("vector_add.cl", "r");
    if (!fp) {
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    source_str = (char*)malloc(MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);
    
    // Get platform and device information
    ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_ALL, 1, &device_id, &ret_num_devices);
    
    // Create OpenCL context
    context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);
    
    // Create command queue
    command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
    
    // Create memory buffers on the device
    a_mem_obj = clCreateBuffer(context, CL_MEM_READ_ONLY, VECTOR_SIZE * sizeof(float), NULL, &ret);
    b_mem_obj = clCreateBuffer(context, CL_MEM_READ_ONLY, VECTOR_SIZE * sizeof(float), NULL, &ret);
    c_mem_obj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, VECTOR_SIZE * sizeof(float), NULL, &ret);
    
    // Copy input data to memory buffers
    ret = clEnqueueWriteBuffer(command_queue, a_mem_obj, CL_TRUE, 0, VECTOR_SIZE * sizeof(float), a, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, b_mem_obj, CL_TRUE, 0, VECTOR_SIZE * sizeof(float), b, 0, NULL, NULL);
    
    // Create kernel program from source
    program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&source_size, &ret);
    
    // Build kernel program
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    
    // Create OpenCL kernel
    kernel = clCreateKernel(program, "vector_add", &ret);
    
    // Set kernel arguments
    ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&a_mem_obj);
    ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&b_mem_obj);
    ret = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *)&c_mem_obj);
    ret = clSetKernelArg(kernel, 3, sizeof(int), (void *)&VECTOR_SIZE);
    
    // Execute OpenCL kernel
    size_t global_item_size = VECTOR_SIZE;
    size_t local_item_size = 64; // Work group size - can be tuned for EV72
    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    
    // Read result from device
    ret = clEnqueueReadBuffer(command_queue, c_mem_obj, CL_TRUE, 0, VECTOR_SIZE * sizeof(float), c, 0, NULL, NULL);
    
    // Print first 10 results
    printf("First 10 results:\n");
    for (int i = 0; i < 10; i++) {
        printf("c[%d] = %.2f\n", i, c[i]);
    }
    
    // Clean up
    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);
    ret = clReleaseMemObject(a_mem_obj);
    ret = clReleaseMemObject(b_mem_obj);
    ret = clReleaseMemObject(c_mem_obj);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    
    free(a);
    free(b);
    free(c);
    free(source_str);
    
    return 0;
}
