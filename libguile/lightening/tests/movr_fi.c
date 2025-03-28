#include "test.h"

static void
run_test(jit_state_t *j, uint8_t *arena_base, size_t arena_size)
{
  jit_begin(j, arena_base, arena_size);
  size_t align = jit_enter_jit_abi(j, 0, 0, 0);

  jit_movi_f(j, JIT_F0, 3.14159);
  jit_movr_i_f(j, JIT_R0, JIT_F0);
  jit_movr_f_i(j, JIT_F1, JIT_R0);
  jit_leave_jit_abi(j, 0, 0, align);
  jit_retr_f(j, JIT_F1);

  float (*f)(void) = jit_end(j, NULL);

  ASSERT(f() == 3.14159f);
}

int
main (int argc, char *argv[])
{
  return main_helper(argc, argv, run_test);
}
