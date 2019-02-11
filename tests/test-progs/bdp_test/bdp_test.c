#include <stdint.h>
#include <stdio.h>

uint64_t binary_dot_product_hw(uint64_t data, uint64_t kernel_address) {
  uint64_t result = 0;

  // move data to registers
  __asm("MOV X9,  %[data]" : : [data] "r" (data));
  __asm("MOV X10, %[data]" : : [data] "r" (kernel_address));

  // perform operation
  __asm(".long 0b10000011000010100000000100101001");
  //                00      | rm|| im || rn|| rd|

  // __asm("ADD X9, X9, X10");

  // store data back
  __asm("MOV %[result], X9" : [result] "=r" (result) : );

  return result;
}

void print_binary(uint64_t num) {
  for (int i = 0; i < sizeof(uint64_t) * 8; i++) {
    if (i != 0 && i % 4 == 0)
      printf(" ");

    printf("%d", (num & 0x8000000000000000) == 0 ? 0 : 1);
    num <<= 1;
  }
}

int main() {
  uint64_t n1 = 0xffffffffffffffff;
  uint64_t n2 = 0xffffffffffffffff;

  printf("Result = %ld\n", binary_dot_product_hw(n1, n2));

  return 0;
}
