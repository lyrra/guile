/* classes: h_files */

#ifndef SCM_UNIF_H
#define SCM_UNIF_H

/* Copyright (C) 1995,1996,1997,1999,2000,2001 Free Software Foundation, Inc.
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



/*
  an array SCM is a non-immediate pointing to a  heap cell where:

   CAR: bits 0-15 hold the smob type id: scm_tc16_array
        bit  16 is the SCM_ARRAY_FLAG_CONTIGUOUS flag
	bits 17-31 hold the dimension (0 -- 32767)
   CDR: pointer to a malloced block containing an scm_t_array structure
        followed by an scm_t_array_dim structure for each dimension.
*/

typedef struct scm_t_array
{
  SCM v;  /* the contents of the array, e.g., a vector or uniform vector.  */
  unsigned long base;
} scm_t_array;

typedef struct scm_t_array_dim
{
  long lbnd;
  long ubnd;
  long inc;
} scm_t_array_dim;

SCM_API scm_t_bits scm_tc16_array;

#define SCM_ARRAY_FLAG_CONTIGUOUS (1 << 16)

#define SCM_ARRAYP(a) 	    SCM_TYP16_PREDICATE (scm_tc16_array, a)
#define SCM_ARRAY_NDIM(x)   ((size_t) (SCM_CELL_WORD_0 (x) >> 17))
#define SCM_ARRAY_CONTP(x)  (SCM_CELL_WORD_0 (x) & SCM_ARRAY_FLAG_CONTIGUOUS)
#define SCM_SET_ARRAY_CONTIGUOUS_FLAG(x) \
  (SCM_SET_CELL_WORD_0 ((x), SCM_CELL_WORD_0 (x) | SCM_ARRAY_FLAG_CONTIGUOUS))
#define SCM_CLR_ARRAY_CONTIGUOUS_FLAG(x) \
  (SCM_SET_CELL_WORD_0 ((x), SCM_CELL_WORD_0 (x) & ~SCM_ARRAY_FLAG_CONTIGUOUS))

#define SCM_ARRAY_MEM(a)  ((scm_t_array *) SCM_CELL_WORD_1 (a))
#define SCM_ARRAY_V(a) 	  (SCM_ARRAY_MEM (a)->v)
#define SCM_ARRAY_BASE(a) (SCM_ARRAY_MEM (a)->base)
#define SCM_ARRAY_DIMS(a) ((scm_t_array_dim *)((char *) SCM_ARRAY_MEM (a) + sizeof (scm_t_array))) 

#define SCM_I_MAX_LENGTH  ((unsigned long) (-1L) >> 8)

#define SCM_UVECTOR_BASE(x) ((void *) (SCM_CELL_WORD_1 (x)))
#define SCM_SET_UVECTOR_BASE(v, b) (SCM_SET_CELL_WORD_1 ((v), (b)))
#define SCM_UVECTOR_MAX_LENGTH SCM_I_MAX_LENGTH
#define SCM_UVECTOR_LENGTH(x) (((unsigned long) SCM_CELL_WORD_0 (x)) >> 8)
#define SCM_MAKE_UVECTOR_TAG(l, t)  (((l) << 8) + (t))
#define SCM_SET_UVECTOR_LENGTH(v, l, t) (SCM_SET_CELL_WORD_0 ((v), SCM_MAKE_UVECTOR_TAG(l, t)))

#define SCM_BITVECTOR_P(x) (!SCM_IMP (x) && (SCM_TYP7 (x) == scm_tc7_bvect))
#define SCM_BITVECTOR_BASE(x) ((unsigned long *) (SCM_CELL_WORD_1 (x)))
#define SCM_SET_BITVECTOR_BASE(v, b) (SCM_SET_CELL_WORD_1 ((v), (b)))
#define SCM_BITVECTOR_MAX_LENGTH SCM_I_MAX_LENGTH
#define SCM_BITVECTOR_LENGTH(x) (((unsigned long) SCM_CELL_WORD_0 (x)) >> 8)
#define SCM_MAKE_BITVECTOR_TAG(l)  (((l) << 8) + scm_tc7_bvect)
#define SCM_SET_BITVECTOR_LENGTH(v, l) (SCM_SET_CELL_WORD_0 ((v), SCM_MAKE_BITVECTOR_TAG (l)))



SCM_API size_t scm_uniform_element_size (SCM obj);
SCM_API SCM scm_make_uve (long k, SCM prot);
SCM_API SCM scm_uniform_vector_length (SCM v);
SCM_API SCM scm_array_p (SCM v, SCM prot);
SCM_API SCM scm_array_rank (SCM ra);
SCM_API SCM scm_array_dimensions (SCM ra);
SCM_API SCM scm_shared_array_root (SCM ra);
SCM_API SCM scm_shared_array_offset (SCM ra);
SCM_API SCM scm_shared_array_increments (SCM ra);
SCM_API long scm_aind (SCM ra, SCM args, const char *what);
SCM_API SCM scm_make_ra (int ndim);
SCM_API SCM scm_shap2ra (SCM args, const char *what);
SCM_API SCM scm_dimensions_to_uniform_array (SCM dims, SCM prot, SCM fill);
SCM_API void scm_ra_set_contp (SCM ra);
SCM_API SCM scm_make_shared_array (SCM oldra, SCM mapfunc, SCM dims);
SCM_API SCM scm_transpose_array (SCM ra, SCM args);
SCM_API SCM scm_enclose_array (SCM ra, SCM axes);
SCM_API SCM scm_array_in_bounds_p (SCM v, SCM args);
SCM_API SCM scm_uniform_vector_ref (SCM v, SCM args);
SCM_API SCM scm_cvref (SCM v, unsigned long pos, SCM last);
SCM_API SCM scm_array_set_x (SCM v, SCM obj, SCM args);
SCM_API SCM scm_array_contents (SCM ra, SCM strict);
SCM_API SCM scm_ra2contig (SCM ra, int copy);
SCM_API SCM scm_uniform_array_read_x (SCM ra, SCM port_or_fd, SCM start, SCM end);
SCM_API SCM scm_uniform_array_write (SCM v, SCM port_or_fd, SCM start, SCM end);
SCM_API SCM scm_bit_count (SCM item, SCM seq);
SCM_API SCM scm_bit_position (SCM item, SCM v, SCM k);
SCM_API SCM scm_bit_set_star_x (SCM v, SCM kv, SCM obj);
SCM_API SCM scm_bit_count_star (SCM v, SCM kv, SCM obj);
SCM_API SCM scm_bit_invert_x (SCM v);
SCM_API SCM scm_istr2bve (char *str, long len);
SCM_API SCM scm_array_to_list (SCM v);
SCM_API SCM scm_list_to_uniform_array (SCM ndim, SCM prot, SCM lst);
SCM_API int scm_raprin1 (SCM exp, SCM port, scm_print_state *pstate);
SCM_API SCM scm_array_prototype (SCM ra);
SCM_API void scm_init_unif (void);

#endif  /* SCM_UNIF_H */

/*
  Local Variables:
  c-file-style: "gnu"
  End:
*/
