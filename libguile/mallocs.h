/* classes: h_files */

#ifndef SCM_MALLOCS_H
#define SCM_MALLOCS_H

/* Copyright (C) 1995,2000 Free Software Foundation, Inc.
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


SCM_API scm_t_bits scm_tc16_malloc;

#define SCM_MALLOCP(X)  (SCM_TYP16 (X) == scm_tc16_malloc)
#define SCM_MALLOCDATA(obj) ((char *) SCM_CELL_WORD_1 (obj))
#define SCM_SETMALLOCDATA(obj, val) (SCM_SET_CELL_WORD_1 (obj, val))



SCM_API SCM scm_malloc_obj (size_t n);
SCM_API void scm_init_mallocs (void);

#endif  /* SCM_MALLOCS_H */

/*
  Local Variables:
  c-file-style: "gnu"
  End:
*/
