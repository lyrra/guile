/* This file contains definitions for deprecated features.  When you
   deprecate something, move it here when that is feasible.
*/

#ifndef SCM_DEPRECATED_H
#define SCM_DEPRECATED_H

/* Copyright (C) 2003 Free Software Foundation, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include "libguile/__scm.h"
#include "libguile/strings.h"

#if (SCM_ENABLE_DEPRECATED == 1)

#define scm_substring_move_left_x scm_substring_move_x
#define scm_substring_move_right_x scm_substring_move_x

typedef long long long_long;
typedef unsigned long long ulong_long;

#define scm_sizet size_t

SCM_API SCM scm_wta (SCM arg, const char *pos, const char *s_subr);

#define SCM_WNA 		8
#define SCM_OUTOFRANGE         10
#define SCM_NALLOC             11

SCM_API void scm_register_module_xxx (char *module_name, void *init_func);
SCM_API SCM scm_registered_modules (void);
SCM_API SCM scm_clear_registered_modules (void);

void scm_i_init_deprecated (void);

#endif

#endif /* SCM_DEPRECATED_H */

#if 0 
/* TODO */

scm_eval_3
scm_eval2

SCM_SETAND_CAR
SCM_SETOR_CAR
SCM_SETAND_CDR
SCM_SETOR_CDR

SCM_FREEP
SCM_NFREEP
SCM_GC8MARKP
SCM_SETGC8MARK
SCM_CLRGC8MARK

SCM_GCTYP16
SCM_GCCDR
scm_remember
scm_protect_object
scm_unprotect_object

scm_module_full_name

scm_the_root_module
scm_make_module
scm_ensure_user_module

scm_load_scheme_module
scm_port
scm_ptob_descriptor
scm_port_rw_active

scm_close_all_ports_except
scm_rstate
scm_rng
scm_i_rstate

SCM_SLOPPY_STRINGP
SCM_RWSTRINGP
SCM_STRING_UCHARS
SCM_STRING_CHARS

scm_read_only_string_p
scm_makstr
scm_makfromstr

scm_make_shared_substring
scm_tc7_substring

SCM_SLOPPY_CONSP
SCM_SLOPPY_NCONSP
scm_tc7_ssymbol
scm_tc7_msymbol
scm_tcs_symbols

scm_variable_set_name_hint
scm_builtin_variable
SCM_VARVCELL
SCM_UDVARIABLEP
SCM_DEFVARIABLEP
scm_internal_with_fluids

scm_make_gsubr
scm_make_gsubr_with_generic
scm_create_hook
list*

SCM_LIST0
SCM_LIST1
SCM_LIST2
SCM_LIST3
SCM_LIST4
SCM_LIST5
SCM_LIST6
SCM_LIST7
SCM_LIST8
SCM_LIST9

scm_listify
scm_sloppy_memq
scm_sloppy_memv
scm_sloppy_member

scm_end_of_file_key
scm_read_and_eval_x

scm_mkbig
scm_big2inum
scm_adjbig
scm_normbig

scm_copybig
scm_2ulong2big
scm_dbl2big
scm_big2dbl
SCM_FIXNUM_BIT

scm_subr_entry
SCM_SUBR_DOC
scm_make_subr_opt
scm_make_subr

scm_make_subr_with_generic

scm_call_catching_errors
scm_make_smob_type_mfpe
scm_set_smob_mfpe

scm_strprint_obj
scm_read_0str
scm_eval_0str
SCM_CHARS
SCM_UCHARS

SCM_SETCHARS
SCM_SLOPPY_SUBSTRP
SCM_SUBSTR_STR
SCM_SUBSTR_OFFSET

SCM_LENGTH_MAX
SCM_LENGTH
SCM_SETLENGTH
SCM_ROSTRINGP
SCM_ROLENGTH

SCM_ROCHARS
SCM_ROUCHARS
SCM_SUBSTRP
SCM_COERCE_SUBSTR
scm_strhash

scm_sym2vcell
scm_sym2ovcell_soft
scm_sym2ovcell

scm_intern_obarray_soft
scm_intern_obarray
scm_intern
scm_intern0

scm_sysintern
scm_sysintern0
scm_sysintern0_no_module_lookup

scm_symbol_value0
scm_string_to_obarray_symbol
scm_intern_symbol

scm_unintern_symbol
scm_symbol_binding
scm_symbol_interned_p

scm_symbol_bound_p
scm_symbol_set_x
scm_gentemp

scm_init_symbols_deprecated
scm_vector_set_length_x

SCM_OPDIRP

scm_fport
scm_option
SCM_CONST_LONG
SCM_VCELL
SCM_GLOBAL_VCELL

SCM_VCELL_INIT
SCM_GLOBAL_VCELL_INIT
scm_srcprops
scm_srcprops_chunk

scm_info_frame
scm_stack
scm_array
scm_array_dim
SCM_ARRAY_CONTIGUOUS

SCM_HUGE_LENGTH
SCM_FUNC_NAME
SCM_WTA
RETURN_SCM_WTA

SCM_VALIDATE_NUMBER_COPY
SCM_VALIDATE_NUMBER_DEF_COPY

SCM_VALIDATE_STRINGORSUBSTR
SCM_VALIDATE_ROSTRING

SCM_VALIDATE_ROSTRING_COPY
SCM_VALIDATE_NULLORROSTRING_COPY

SCM_VALIDATE_RWSTRING
SCM_VALIDATE_OPDIR
scm_small_istr2int

scm_istr2int
scm_istr2flo
scm_istring2number
scm_istr2int

scm_istr2flo
scm_istring2number
scm_vtable_index_vcell

SCM_ECONSP
SCM_NECONSP

scm_tc16_variable

#endif
