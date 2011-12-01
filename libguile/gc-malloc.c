/* Copyright (C) 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003,
 *   2004, 2006, 2008, 2009, 2010, 2011 Free Software Foundation, Inc.
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



#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <errno.h>
#include <string.h>

#ifdef __ia64__
#include <ucontext.h>
extern unsigned long * __libc_ia64_register_backing_store_base;
#endif

#include "libguile/_scm.h"
#include "libguile/eval.h"
#include "libguile/stime.h"
#include "libguile/stackchk.h"
#include "libguile/struct.h"
#include "libguile/smob.h"
#include "libguile/arrays.h"
#include "libguile/async.h"
#include "libguile/ports.h"
#include "libguile/root.h"
#include "libguile/strings.h"
#include "libguile/vectors.h"
#include "libguile/hashtab.h"
#include "libguile/tags.h"

#include "libguile/validate.h"
#include "libguile/deprecation.h"
#include "libguile/gc.h"

#include "libguile/private-gc.h"

#ifdef GUILE_DEBUG_MALLOC
#include "libguile/debug-malloc.h"
#endif

#ifdef HAVE_MALLOC_H
#include <malloc.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

/*
  INIT_MALLOC_LIMIT is the initial amount of malloc usage which will
  trigger a GC.
  
  After startup (at the guile> prompt), we have approximately 100k of
  alloced memory, which won't go away on GC. Let's set the init such
  that we get a nice yield on the next allocation:
*/
#define SCM_DEFAULT_INIT_MALLOC_LIMIT 200*1024
#define SCM_DEFAULT_MALLOC_MINYIELD 40

/* #define DEBUGINFO */



/* Function for non-cell memory management.
 */

void *
scm_realloc (void *mem, size_t size)
{
  void *ptr;

  scm_gc_register_allocation (size);

  SCM_SYSCALL (ptr = realloc (mem, size));
  if (ptr)
    return ptr;

  /* Time is hard: trigger a full, ``stop-the-world'' GC, and try again.  */
  GC_gcollect_and_unmap ();

  SCM_SYSCALL (ptr = realloc (mem, size));
  if (ptr)
    return ptr;

  scm_memory_error ("realloc");
}

void *
scm_malloc (size_t sz)
{
  return scm_realloc (NULL, sz);
}

/*
  Hmm. Should we use the C convention for arguments (i.e. N_ELTS,
  SIZEOF_ELT)? --hwn
 */
void *
scm_calloc (size_t sz)
{
  void * ptr;

  /*
    By default, try to use calloc, as it is likely more efficient than
    calling memset by hand.
   */
  SCM_SYSCALL (ptr = calloc (sz, 1));
  if (ptr)
    return ptr;

  ptr = scm_realloc (NULL, sz);
  memset (ptr, 0x0, sz);
  return ptr;
}


char *
scm_strndup (const char *str, size_t n)
{
  char *dst = scm_malloc (n + 1);
  memcpy (dst, str, n);
  dst[n] = 0;
  return dst;
}

char *
scm_strdup (const char *str)
{
  return scm_strndup (str, strlen (str));
}



void
scm_gc_register_collectable_memory (void *mem, size_t size, const char *what)
{
  /* Nothing to do.  */
#ifdef GUILE_DEBUG_MALLOC
  if (mem)
    scm_malloc_register (mem, what);
#endif
}


void
scm_gc_unregister_collectable_memory (void *mem, size_t size, const char *what)
{
  /* Nothing to do.  */
#ifdef GUILE_DEBUG_MALLOC
  if (mem)
    scm_malloc_unregister (mem);
#endif
}

/* Allocate SIZE bytes of memory whose contents should not be scanned
   for pointers (useful, e.g., for strings).  Note though that this
   memory is *not* cleared; be sure to initialize it to prevent
   information leaks.  */
void *
scm_gc_malloc_pointerless (size_t size, const char *what)
{
  return GC_MALLOC_ATOMIC (size);
}

void *
scm_gc_malloc (size_t size, const char *what)
{
  void *ptr;

  if (size == 0)
    /* `GC_MALLOC ()' doesn't handle zero.  */
    size = sizeof (void *);

  ptr = GC_MALLOC (size);

  return ptr;
}

void *
scm_gc_calloc (size_t size, const char *what)
{
  /* `GC_MALLOC ()' always returns a zeroed buffer.  */
  return scm_gc_malloc (size, what);
}


void *
scm_gc_realloc (void *mem, size_t old_size, size_t new_size, const char *what)
{
  void *ptr;

  ptr = GC_REALLOC (mem, new_size);

#ifdef GUILE_DEBUG_MALLOC
  if (mem)
    scm_malloc_reregister (mem, ptr, what);
#endif

  return ptr;
}

void
scm_gc_free (void *mem, size_t size, const char *what)
{
  scm_gc_unregister_collectable_memory (mem, size, what);
  GC_FREE (mem);
}

char *
scm_gc_strndup (const char *str, size_t n, const char *what)
{
  char *dst = GC_MALLOC_ATOMIC (n + 1);
  memcpy (dst, str, n);
  dst[n] = 0;
  return dst;
}

char *
scm_gc_strdup (const char *str, const char *what)
{
  return scm_gc_strndup (str, strlen (str), what);
}
