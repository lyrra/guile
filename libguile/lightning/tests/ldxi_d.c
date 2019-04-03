#include "test.h"

static double data[] = { -1.0, 0.0, 0.5 };

static void
run_test(jit_state_t *j, uint8_t *arena_base, size_t arena_size)
{
  jit_begin(j, arena_base, arena_size);

  const jit_arg_abi_t abi[] = { JIT_ARG_ABI_INTMAX };
  jit_arg_t args[1];
  const jit_anyreg_t regs[] = { { .gpr=JIT_R0 } };

  jit_receive(j, 1, abi, args);
  jit_load_args(j, 1, abi, args, regs);

  jit_ldxi_d(j, JIT_F0, JIT_R0, (uintptr_t)data);
  jit_retr_d(j, JIT_F0);

  double (*f)(uintmax_t) = jit_end(j, NULL);

  ASSERT(f(0) == data[0]);
  ASSERT(f(8) == data[1]);
  ASSERT(f(16) == data[2]);
}

int
main (int argc, char *argv[])
{
  return main_helper(argc, argv, run_test);
}
