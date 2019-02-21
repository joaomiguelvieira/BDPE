#include <stdint.h>
#include <stdio.h>

uint64_t test_function() {
  register uint64_t res = 1;
  register uint64_t one = 1;

  __asm( //"cmp %[one], 0x2\n\t"
         ".long 0b10000011000010100000000100101001\n\t"
         "b.vs 0x8\n\t"
         "add %[res], %[val], 0x1\n\t" : [res] "=r" (res) : [one] "r" (one), [val] "r" (res));

  return res;
}

// uint64_t bdp_hw(uint64_t *ptr_d, uint64_t *ptr_k) {
//   uint64_t result;
//   uint64_t tmp1, tmp2;

//   // backup registers
//   __asm("STR X9,  [%[x9_str]]\n\t"                     // backup register x9
//         "STR X10, [%[x10_str]]\n\t"                    // backup register x10
//         "LDR X9,  [%[d_mem]]\n\t"                      // load data into register x9
//         "LDR X10, [%[k_mem]]\n\t"                      // load kernel into register x10
//         ".long 0b10000011000010100000000100101001\n\t" // issue operation
//         "STR X9,  [%[r_mem]]\n\t"                      // store operation result
//         "LDR X9,  [%[x9_ldr]]\n\t"                     // backup register x9
//         "LDR X10, [%[x10_ldr]]\n\t"                    // backup register x10
//         : : [x9_str]  "r" (&tmp1),
//             [x10_str] "r" (&tmp2),
//             [d_mem]   "r" (ptr_d),
//             [k_mem]   "r" (ptr_k),
//             [r_mem]   "r" (&result),
//             [x9_ldr]  "r" (&tmp1),
//             [x10_ldr] "r" (&tmp2)
//   );

//   return result;
// }

// void print_binary(uint64_t num) {
//   for (int i = 0; i < sizeof(uint64_t) * 8; i++) {
//     if (i != 0 && i % 4 == 0)
//       printf(" ");

//     printf("%d", (num & 0x8000000000000000) == 0 ? 0 : 1);
//     num <<= 1;
//   }
// }

int main() {
  // uint64_t n1 = 0xffffffffffffffff;
  // uint64_t n2 = 0xffffffffffffffff;

  // printf("Result = %ld\n", bdp_hw(&n1, &n2));
  // return 0;

  printf("The result is %ld\n", test_function());

  return 0;
}
