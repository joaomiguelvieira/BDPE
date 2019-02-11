#include <bitset>
#include <iostream>

#define MATRIX_SIZE 32
#define KERNEL_SIZE 5
#define KERNEL_PADDING KERNEL_SIZE / 2
#define KERNEL_MASK 0x0000001f

#define KERNEL 0xffffffff

int binary_dot_product_hw(int data, int kernel_address) {
  int result = 0;

  // move data to registers
  __asm("MOV X9,  %[data]" : : [data] "r" (data));
  __asm("MOV X10, %[data]" : : [data] "r" (kernel_address));

  // perform operation
  __asm(".long 0b00000001000010100000000100101001");
  //             |||        | rm||t||i|| rn|| rd|

  // store data back
  __asm("MOV %[result], X9" : [result] "=r" (result) : );

  return result;
}

int binary_dot_product_sw(int data) {
  int result = 0;
  int kernel = KERNEL;
  int vector = data;

  for (int i = 0; i < KERNEL_SIZE * KERNEL_SIZE; i++) {
    result += ((kernel & 1) == (vector & 1)) ? 1 : 0;
    kernel >>= 1;
    vector >>= 1;
  }

  return result;
}

void print_binary(int num) {
  for (int i = 0; i < sizeof(int) * 8; i++) {
    if (i != 0 && i % 4 == 0)
      printf(" ");

    printf("%d", (num & 0x80000000) == 0 ? 0 : 1);
    num <<= 1;
  }
}

int vectorize(unsigned int *matrix, int row, int column) {
  int vector = 0;

  for (int i = 0; i < KERNEL_SIZE; i++) {
    int j = (matrix[row + i - KERNEL_PADDING] >> (MATRIX_SIZE - column - KERNEL_PADDING - 1)) & KERNEL_MASK;
    vector |= j << (KERNEL_SIZE - i - 1) * KERNEL_SIZE;
  }

  return vector;
}

void convolution_hw(unsigned int *matrix, int kernel_address, int result[MATRIX_SIZE][MATRIX_SIZE]) {
  for (int i = KERNEL_PADDING; i < MATRIX_SIZE - KERNEL_PADDING; i++)
    for (int j = KERNEL_PADDING; j < MATRIX_SIZE - KERNEL_PADDING; j++)
      result[i][j] = binary_dot_product_hw(vectorize(matrix, i, j), kernel_address);
}

void convolution_sw(unsigned int *matrix, int result[MATRIX_SIZE][MATRIX_SIZE]) {
  for (int i = KERNEL_PADDING; i < MATRIX_SIZE - KERNEL_PADDING; i++)
    for (int j = KERNEL_PADDING; j < MATRIX_SIZE - KERNEL_PADDING; j++)
      result[i][j] = binary_dot_product_sw(vectorize(matrix, i, j));
}

int convolution_check(int result_hw[MATRIX_SIZE][MATRIX_SIZE], int result_sw[MATRIX_SIZE][MATRIX_SIZE]) {
  for (int i = KERNEL_PADDING; i < MATRIX_SIZE - KERNEL_PADDING; i++)
    for (int j = KERNEL_PADDING; j < MATRIX_SIZE - KERNEL_PADDING; j++)
      if (result_hw[i][j] != result_sw[i][j])
        return -1;

  return 0;
}

void print_result(int result[MATRIX_SIZE][MATRIX_SIZE]) {
  for (int i = KERNEL_PADDING; i < MATRIX_SIZE - KERNEL_PADDING; i++) {
    for (int j = KERNEL_PADDING; j < MATRIX_SIZE - KERNEL_PADDING; j++)
      printf("%d ", result[i][j]);

    printf("\n");
  }
}

int main() {
  unsigned int matrix[MATRIX_SIZE] = { 0b00000000000000000000000000000000 ,
                                       0b01000000000000000000000000000000 ,
                                       0b00100000000000000000000000000000 ,
                                       0b00010000000000000000000000000000 ,
                                       0b00001000000000000000000000000000 ,
                                       0b00000100000000000000000000000000 ,
                                       0b00000010000000000000000000000000 ,
                                       0b00000001000000000000000000000000 ,
                                       0b00000000100000000000000000000000 ,
                                       0b00000000010000000000000000000000 ,
                                       0b00000000001000000000000000000000 ,
                                       0b00000000000100000000000000000000 ,
                                       0b00000000000010000000000000000000 ,
                                       0b00000000000001000000000000000000 ,
                                       0b00000000000000100000000000000000 ,
                                       0b00000000000000010000000000000000 ,
                                       0b00000000000000001000000000000000 ,
                                       0b00000000000000000100000000000000 ,
                                       0b00000000000000000010000000000000 ,
                                       0b00000000000000000001000000000000 ,
                                       0b00000000000000000000100000000000 ,
                                       0b00000000000000000000010000000000 ,
                                       0b00000000000000000000001000000000 ,
                                       0b00000000000000000000000100000000 ,
                                       0b00000000000000000000000010000000 ,
                                       0b00000000000000000000000001000000 ,
                                       0b00000000000000000000000000100000 ,
                                       0b00000000000000000000000000010000 ,
                                       0b00000000000000000000000000001000 ,
                                       0b00000000000000000000000000000100 ,
                                       0b00000000000000000000000000000010 ,
                                       0b00000000000000000000000000000000 };

  int result_hw[MATRIX_SIZE][MATRIX_SIZE], result_sw[MATRIX_SIZE][MATRIX_SIZE];

  convolution_hw(matrix, 0, result_hw);
  convolution_sw(matrix, result_sw);

  if (convolution_check(result_hw, result_sw) != 0)
    printf("[ERROR] Convolution not successful!\n");

  print_result(result_hw);
  print_result(result_sw);

  return 0;
}
