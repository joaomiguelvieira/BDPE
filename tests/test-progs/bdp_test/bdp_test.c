#include <stdint.h>
#include <stdio.h>

uint64_t bdp_hw(uint64_t data, uint64_t *ptr_k) {
  register uint64_t result;

  __asm("sub sp, sp, 0x10\n\t"                         // open some space in the stack
        "stp x10, x11, [sp]\n\t"                       // save pair of registers

        "mov x10, %[ptr_k]\n\t"                        // move kernel address to register x11
        "mov x11, %[data]\n\t"                         // move data to register x10
        ".long 0b10000011000010100000000101101010\n\t" // check if kernel is cached
        "cmp x10, 0x40\n\t"                            // compare the returned address with null
        "b.ls 0xc\n\t"                                 // branch if not null (use cached kernel)
        "ldr x10, [%[ptr_k]]\n\t"                      // load kernel from memory
        ".long 0b11000011000010100000000101101010\n\t" // issue operation using data and kernel from memory
        "mov %[res], x10\n\t"                          // put result in place

        "ldp x10, x11, [sp]\n\t"                       // restore pair of registers
        "add sp, sp, 0x10\n\t"                         // free the space in the stack
        : [res]        "=r" (result)
        : [data]       "r"  (data),
          [ptr_k]      "r"  (ptr_k)
  );

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
  uint64_t n1 = 0xfffffffffffffff1;
  uint64_t n2 = 0xfffffffffffffff2;

  printf("Result = %ld\n", bdp_hw(n1, &n2));

  return 0;
}
