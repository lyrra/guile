/* classes: h_files */

#ifndef SCM_EVALEXT_H
#define SCM_EVALEXT_H

/* Copyright (C) 1998,1999,2000, 2003 Free Software Foundation, Inc.
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



SCM_API SCM scm_m_generalized_set_x (SCM xorig, SCM env);
SCM_API SCM scm_defined_p (SCM sym, SCM env);
SCM_API SCM scm_self_evaluating_p (SCM obj);
SCM_API void scm_init_evalext (void);

#if (SCM_ENABLE_DEPRECATED == 1)

#define scm_definedp scm_defined_p
SCM_API SCM scm_m_undefine (SCM x, SCM env);

#endif

#endif  /* SCM_EVALEXT_H */

/*
  Local Variables:
  c-file-style: "gnu"
  End:
*/
