/* Copyright (C) 2001, 2009 Free Software Foundation, Inc.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#if HAVE_CONFIG_H
#  include <config.h>
#endif

#include <string.h>
#include "_scm.h"
#include "vm-bootstrap.h"
#include "instructions.h"
#include "modules.h"
#include "programs.h"
#include "procprop.h" /* scm_sym_name */
#include "srcprop.h"  /* scm_sym_filename */
#include "vm.h"


static SCM write_program = SCM_BOOL_F;

SCM_DEFINE (scm_make_program, "make-program", 1, 2, 0,
	    (SCM objcode, SCM objtable, SCM free_variables),
	    "")
#define FUNC_NAME s_scm_make_program
{
  SCM_VALIDATE_OBJCODE (1, objcode);
  if (SCM_UNLIKELY (SCM_UNBNDP (objtable)))
    objtable = SCM_BOOL_F;
  else if (scm_is_true (objtable))
    SCM_VALIDATE_VECTOR (2, objtable);
  if (SCM_UNLIKELY (SCM_UNBNDP (free_variables)))
    free_variables = SCM_BOOL_F;
  else if (free_variables != SCM_BOOL_F)
    SCM_VALIDATE_VECTOR (3, free_variables);

  return scm_double_cell (scm_tc7_program, (scm_t_bits)objcode,
                          (scm_t_bits)objtable, (scm_t_bits)free_variables);
}
#undef FUNC_NAME

void
scm_i_program_print (SCM program, SCM port, scm_print_state *pstate)
{
  static int print_error = 0;

  if (scm_is_false (write_program) && scm_module_system_booted_p)
    write_program = scm_module_local_variable
      (scm_c_resolve_module ("system vm program"),
       scm_from_locale_symbol ("write-program"));
  
  if (scm_is_false (write_program) || print_error)
    {
      scm_puts ("#<program ", port);
      scm_uintprint (SCM_CELL_WORD_1 (program), 16, port);
      scm_putc ('>', port);
    }
  else
    {
      print_error = 1;
      scm_call_2 (SCM_VARIABLE_REF (write_program), program, port);
      print_error = 0;
    }
}


/*
 * Scheme interface
 */

SCM_DEFINE (scm_program_p, "program?", 1, 0, 0,
	    (SCM obj),
	    "")
#define FUNC_NAME s_scm_program_p
{
  return scm_from_bool (SCM_PROGRAM_P (obj));
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_base, "program-base", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_base
{
  SCM_VALIDATE_PROGRAM (1, program);

  return scm_from_ulong ((unsigned long) SCM_PROGRAM_DATA (program)->base);
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_objects, "program-objects", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_objects
{
  SCM_VALIDATE_PROGRAM (1, program);
  return SCM_PROGRAM_OBJTABLE (program);
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_module, "program-module", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_module
{
  SCM objs;
  SCM_VALIDATE_PROGRAM (1, program);
  objs = SCM_PROGRAM_OBJTABLE (program);
  return scm_is_true (objs) ? scm_c_vector_ref (objs, 0) : SCM_BOOL_F;
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_meta, "program-meta", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_meta
{
  SCM metaobj;
  
  SCM_VALIDATE_PROGRAM (1, program);

  metaobj = scm_objcode_meta (SCM_PROGRAM_OBJCODE (program));
  if (scm_is_true (metaobj))
    return scm_make_program (metaobj, SCM_BOOL_F, SCM_BOOL_F);
  else
    return SCM_BOOL_F;
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_bindings, "program-bindings", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_bindings
{
  SCM meta;
  
  SCM_VALIDATE_PROGRAM (1, program);

  meta = scm_program_meta (program);
  if (scm_is_false (meta))
    return SCM_BOOL_F;
  
  return scm_car (scm_call_0 (meta));
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_sources, "program-sources", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_sources
{
  SCM meta, sources, ret, filename;
  
  SCM_VALIDATE_PROGRAM (1, program);

  meta = scm_program_meta (program);
  if (scm_is_false (meta))
    return SCM_EOL;
  
  filename = SCM_BOOL_F;
  ret = SCM_EOL;
  for (sources = scm_cadr (scm_call_0 (meta)); !scm_is_null (sources);
       sources = scm_cdr (sources))
    {
      SCM x = scm_car (sources);
      if (scm_is_pair (x))
        {
          if (scm_is_number (scm_car (x)))
            {
              SCM addr = scm_car (x);
              ret = scm_acons (addr, scm_cons (filename, scm_cdr (x)),
                               ret);
            }
          else if (scm_is_eq (scm_car (x), scm_sym_filename))
            filename = scm_cdr (x);
        }
    }
  return scm_reverse_x (ret, SCM_UNDEFINED);
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_arities, "program-arities", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_arities
{
  SCM meta;
  
  SCM_VALIDATE_PROGRAM (1, program);

  meta = scm_program_meta (program);
  if (scm_is_false (meta))
    return SCM_BOOL_F;

  return scm_caddr (scm_call_0 (meta));
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_properties, "program-properties", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_properties
{
  SCM meta;
  
  SCM_VALIDATE_PROGRAM (1, program);

  meta = scm_program_meta (program);
  if (scm_is_false (meta))
    return SCM_EOL;
  
  return scm_cdddr (scm_call_0 (meta));
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_name, "program-name", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_name
{
  SCM_VALIDATE_PROGRAM (1, program);
  return scm_assq_ref (scm_program_properties (program), scm_sym_name);
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_source, "program-source", 2, 0, 0,
	    (SCM program, SCM ip),
	    "")
#define FUNC_NAME s_scm_program_source
{
  SCM_VALIDATE_PROGRAM (1, program);
  return scm_c_program_source (program, scm_to_size_t (ip));
}
#undef FUNC_NAME
    
extern SCM
scm_c_program_source (SCM program, size_t ip)
{
  SCM sources, source = SCM_BOOL_F;

  for (sources = scm_program_sources (program);
       !scm_is_null (sources)
         && scm_to_size_t (scm_caar (sources)) <= ip;
       sources = scm_cdr (sources))
    source = scm_car (sources);
  
  return source; /* (addr . (filename . (line . column))) */
}

SCM_DEFINE (scm_program_free_variables, "program-free-variables", 1, 0, 0,
	    (SCM program),
	    "")
#define FUNC_NAME s_scm_program_free_variables
{
  SCM_VALIDATE_PROGRAM (1, program);
  return SCM_PROGRAM_FREE_VARIABLES (program);
}
#undef FUNC_NAME

SCM_DEFINE (scm_program_objcode, "program-objcode", 1, 0, 0,
	    (SCM program),
	    "Return a @var{program}'s object code.")
#define FUNC_NAME s_scm_program_objcode
{
  SCM_VALIDATE_PROGRAM (1, program);

  return SCM_PROGRAM_OBJCODE (program);
}
#undef FUNC_NAME

/* This one is a shim to pre-case-lambda internal interfaces. Avoid it if you
   can -- use program-arguments or the like. */
static SCM sym_arglist;
int
scm_i_program_arity (SCM program, int *req, int *opt, int *rest)
{
  SCM arities, x;
  
  arities = scm_program_arities (program);
  if (!scm_is_pair (arities))
    return 0;
  /* take the last arglist, it will be least specific */
  while (scm_is_pair (scm_cdr (arities)))
    arities = scm_cdr (arities);
  x = scm_cddar (arities);
  if (scm_is_pair (x))
    {
      *req = scm_to_int (scm_car (x));
      x = scm_cdr (x);
      if (scm_is_pair (x))
        {
          *opt = scm_to_int (scm_car (x));
          x = scm_cdr (x);
          if (scm_is_pair (x))
            *rest = scm_is_true (scm_car (x));
          else
            *rest = 0;
        }
      else
        *opt = *rest = 0;
    }
  else
    *req = *opt = *rest = 0;
          
  return 1;
}



void
scm_bootstrap_programs (void)
{
  /* arglist can't be snarfed, because snarfage is only loaded when (system vm
     program) is loaded. perhaps static-alloc will fix this. */
  sym_arglist = scm_from_locale_symbol ("arglist");
  scm_c_register_extension ("libguile", "scm_init_programs",
                            (scm_t_extension_init_func)scm_init_programs, NULL);
}

void
scm_init_programs (void)
{
  scm_bootstrap_vm ();
  
#ifndef SCM_MAGIC_SNARFER
#include "libguile/programs.x"
#endif
}

/*
  Local Variables:
  c-file-style: "gnu"
  End:
*/
