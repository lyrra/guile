#ifndef SCM_THREADS_H
#define SCM_THREADS_H

/* Copyright 1996-1998,2000-2004,2006-2009,2011-2014,2018-2019
     Free Software Foundation, Inc.

   This file is part of Guile.

   Guile is free software: you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as published
   by the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Guile is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
   License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with Guile.  If not, see
   <https://www.gnu.org/licenses/>.  */



#include "libguile/procs.h"
#include "libguile/throw.h"
#include "libguile/dynstack.h"
#include "libguile/iselect.h"
#include "libguile/smob.h"
#include "libguile/vm.h"

#if SCM_USE_PTHREAD_THREADS
#include "libguile/pthread-threads.h"
#endif

#if SCM_USE_NULL_THREADS
#include "libguile/null-threads.h"
#endif



#define SCM_INLINE_GC_GRANULE_WORDS 2
#define SCM_INLINE_GC_GRANULE_BYTES \
  (sizeof(void *) * SCM_INLINE_GC_GRANULE_WORDS)

/* A freelist set contains SCM_INLINE_GC_FREELIST_COUNT pointers to
   singly linked lists of objects of different sizes, the ith one
   containing objects i + 1 granules in size.  This setting of
   SCM_INLINE_GC_FREELIST_COUNT will hold freelists for allocations of
   up to 256 bytes.  */
#define SCM_INLINE_GC_FREELIST_COUNT (256U / SCM_INLINE_GC_GRANULE_BYTES)



/* smob tags for the thread datatypes */
SCM_API scm_t_bits scm_tc16_thread;
SCM_API scm_t_bits scm_tc16_mutex;
SCM_API scm_t_bits scm_tc16_condvar;

struct scm_thread_wake_data;

struct scm_thread {
  struct scm_thread *next_thread;

  /* VM state for this thread.  */
  struct scm_vm vm;

  /* For system asyncs.
   */
  SCM pending_asyncs;            /* The thunks to be run at the next
                                    safe point.  Accessed atomically. */
  unsigned int block_asyncs;    /* Non-zero means that asyncs should
                                   not be run. */

  /* Thread-local freelists; see gc-inline.h.  */
  void *freelists[SCM_INLINE_GC_FREELIST_COUNT];
  void *pointerless_freelists[SCM_INLINE_GC_FREELIST_COUNT];

  SCM handle;
  scm_i_pthread_t pthread;

  SCM result;
  int exited;

  /* Boolean indicating whether the thread is in guile mode.  */
  int guile_mode;
  /* Boolean indicating whether to call GC_unregister_my_thread () when
     this thread exits.  */
  int needs_unregister;

  struct scm_thread_wake_data *wake;
  scm_i_pthread_cond_t sleep_cond;
  int sleep_pipe[2];

  /* Other thread local things.
   */
  scm_t_dynamic_state *dynamic_state;

  /* The dynamic stack.  */
  scm_t_dynstack dynstack;

  /* The current continuation root and the stack base for it.

     The continuation root is an arbitrary but unique object that
     identifies a dynamic extent.  Continuations created during that
     extent can also only be invoked during it.

     We use pairs where the car is the thread handle and the cdr links
     to the previous pair.  This might be used for better error
     messages but is not essential for identifying continuation roots.

     The continuation base is the far end of the stack upto which it
     needs to be copied.
  */
  SCM continuation_root;
  SCM_STACKITEM *continuation_base;

  /* Stack base.  Used when checking for C stack overflow.  */
  SCM_STACKITEM *base;

  /* JIT state; NULL until this thread needs to JIT-compile something.  */
  struct scm_jit_state *jit_state;
};

#define SCM_I_IS_THREAD(x)    SCM_SMOB_PREDICATE (scm_tc16_thread, x)
#define SCM_I_THREAD_DATA(x)  ((scm_thread *) SCM_SMOB_DATA (x))

#define SCM_VALIDATE_THREAD(pos, a) \
  scm_assert_smob_type (scm_tc16_thread, (a))
#define SCM_VALIDATE_MUTEX(pos, a) \
  scm_assert_smob_type (scm_tc16_mutex, (a))
#define SCM_VALIDATE_CONDVAR(pos, a) \
  scm_assert_smob_type (scm_tc16_condvar, (a))

SCM_API SCM scm_spawn_thread (scm_t_catch_body body, void *body_data,
			      scm_t_catch_handler handler, void *handler_data);

SCM_API void *scm_without_guile (void *(*func)(void *), void *data);
SCM_API void *scm_with_guile (void *(*func)(void *), void *data);

SCM_INTERNAL void scm_threads_prehistory (void *);
SCM_INTERNAL void scm_init_threads (void);
SCM_INTERNAL void scm_init_threads_default_dynamic_state (void);

SCM_INTERNAL void scm_i_dynwind_pthread_mutex_lock_block_asyncs (scm_i_pthread_mutex_t *mutex);

SCM_API SCM scm_call_with_new_thread (SCM thunk, SCM handler);
SCM_API SCM scm_yield (void);
SCM_API SCM scm_cancel_thread (SCM t);
SCM_API SCM scm_join_thread (SCM t);
SCM_API SCM scm_join_thread_timed (SCM t, SCM timeout, SCM timeoutval);
SCM_API SCM scm_thread_p (SCM t);

SCM_API SCM scm_make_mutex (void);
SCM_API SCM scm_make_recursive_mutex (void);
SCM_API SCM scm_make_mutex_with_kind (SCM kind);
SCM_API SCM scm_lock_mutex (SCM m);
SCM_API SCM scm_timed_lock_mutex (SCM m, SCM timeout);
SCM_API void scm_dynwind_lock_mutex (SCM mutex);
SCM_API SCM scm_try_mutex (SCM m);
SCM_API SCM scm_unlock_mutex (SCM m);
SCM_API SCM scm_mutex_p (SCM o);
SCM_API SCM scm_mutex_locked_p (SCM m);
SCM_API SCM scm_mutex_owner (SCM m);
SCM_API SCM scm_mutex_level (SCM m);

SCM_API SCM scm_make_condition_variable (void);
SCM_API SCM scm_wait_condition_variable (SCM cond, SCM mutex);
SCM_API SCM scm_timed_wait_condition_variable (SCM cond, SCM mutex,
					       SCM abstime);
SCM_API SCM scm_signal_condition_variable (SCM cond);
SCM_API SCM scm_broadcast_condition_variable (SCM cond);
SCM_API SCM scm_condition_variable_p (SCM o);

SCM_API SCM scm_current_thread (void);
SCM_API SCM scm_all_threads (void);

SCM_API int scm_c_thread_exited_p (SCM thread);
SCM_API SCM scm_thread_exited_p (SCM thread);

#ifdef BUILDING_LIBGUILE

/* Though we don't need the key for SCM_I_CURRENT_THREAD if we have TLS,
   we do use it for cleanup purposes.  */
SCM_INTERNAL scm_i_pthread_key_t scm_i_thread_key;

# ifdef SCM_HAVE_THREAD_STORAGE_CLASS

SCM_INTERNAL SCM_THREAD_LOCAL scm_thread *scm_i_current_thread;
#  define SCM_I_CURRENT_THREAD (scm_i_current_thread)

# else /* !SCM_HAVE_THREAD_STORAGE_CLASS */

#  define SCM_I_CURRENT_THREAD						\
    ((scm_thread *) scm_i_pthread_getspecific (scm_i_thread_key))

# endif /* !SCM_HAVE_THREAD_STORAGE_CLASS */

#endif /* BUILDING_LIBGUILE */

SCM_INTERNAL scm_i_pthread_mutex_t scm_i_misc_mutex;

/* Convenience functions for working with the pthread API in guile
   mode.
*/

#if SCM_USE_PTHREAD_THREADS
SCM_API int scm_pthread_mutex_lock (pthread_mutex_t *mutex);
SCM_API void scm_dynwind_pthread_mutex_lock (pthread_mutex_t *mutex);
SCM_API int scm_pthread_cond_wait (pthread_cond_t *cond,
				   pthread_mutex_t *mutex);
SCM_API int scm_pthread_cond_timedwait (pthread_cond_t *cond,
					pthread_mutex_t *mutex,
					const scm_t_timespec *abstime);
#endif

/* More convenience functions.
 */

SCM_API unsigned int scm_std_sleep (unsigned int);
SCM_API unsigned long scm_std_usleep (unsigned long);

SCM_API SCM scm_total_processor_count (void);
SCM_API SCM scm_current_processor_count (void);

#endif  /* SCM_THREADS_H */
