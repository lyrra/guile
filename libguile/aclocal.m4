dnl aclocal.m4 generated automatically by aclocal 1.1i

dnl  On the NeXT, #including <utime.h> doesn't give you a definition for
dnl  struct utime, unless you #define _POSIX_SOURCE.

AC_DEFUN(GUILE_STRUCT_UTIMBUF, [
  AC_CACHE_CHECK([whether we need POSIX to get struct utimbuf],
    guile_cv_struct_utimbuf_needs_posix,
    [AC_TRY_CPP([
#ifdef __EMX__
#include <sys/utime.h>
#else
#include <utime.h>
#endif
struct utime blah;
],
                guile_cv_struct_utimbuf_needs_posix=no,
		guile_cv_struct_utimbuf_needs_posix=yes)])
  if test "$guile_cv_struct_utimbuf_needs_posix" = yes; then
     AC_DEFINE(UTIMBUF_NEEDS_POSIX)
  fi])




dnl
dnl Apparently, at CMU they have a weird version of libc.h that is
dnl installed in /usr/local/include and conflicts with unistd.h.
dnl In these situations, we should not #include libc.h.
dnl This test arranges to #define LIBC_H_WITH_UNISTD_H iff libc.h is
dnl present on the system, and is safe to #include.
dnl
AC_DEFUN([GUILE_HEADER_LIBC_WITH_UNISTD],
  [
    AC_CHECK_HEADERS(libc.h unistd.h)
    AC_CACHE_CHECK(
      "whether libc.h and unistd.h can be included together",
      guile_cv_header_libc_with_unistd,
      [
        if test "$ac_cv_header_libc_h" = "no"; then
          guile_cv_header_libc_with_unistd="no"
        elif test "$ac_cv_header_unistd.h" = "no"; then
          guile_cv_header_libc_with_unistd="yes"
        else
          AC_TRY_COMPILE(
	    [
#             include <libc.h>
#             include <unistd.h>
	    ],
	    [],
	    [guile_cv_header_libc_with_unistd=yes],
	    [guile_cv_header_libc_with_unistd=no]
          )
        fi
      ]
    )
    if test "$guile_cv_header_libc_with_unistd" = yes; then
      AC_DEFINE(LIBC_H_WITH_UNISTD_H)
    fi
  ]
)

# Like AC_CONFIG_HEADER, but automatically create stamp file.

AC_DEFUN(AM_CONFIG_HEADER,
[AC_PREREQ([2.12])
AC_CONFIG_HEADER([$1])
dnl When config.status generates a header, we must update the stamp-h file.
dnl This file resides in the same directory as the config header
dnl that is generated.  We must strip everything past the first ":",
dnl and everything past the last "/".
AC_OUTPUT_COMMANDS(changequote(<<,>>)dnl
test -z "<<$>>CONFIG_HEADER" || echo timestamp > patsubst(<<$1>>, <<^\([^:]*/\)?.*>>, <<\1>>)stamp-h<<>>dnl
changequote([,]))])


dnl Usage: AM_INIT_GUILE_MODULE(module-name)
dnl This macro will automatically get the guile version from the
dnl top-level srcdir, and will initialize automake.  It also
dnl defines the `module' variable.
AC_DEFUN([AM_INIT_GUILE_MODULE],[
. $srcdir/../GUILE-VERSION
AM_INIT_AUTOMAKE($PACKAGE, $VERSION)
AC_CONFIG_AUX_DIR(..)
module=[$1]
AC_SUBST(module)])

# Do all the work for Automake.  This macro actually does too much --
# some checks are only needed if your package does certain things.
# But this isn't really a big deal.

# serial 1

dnl Usage:
dnl AM_INIT_AUTOMAKE(package,version)

AC_DEFUN(AM_INIT_AUTOMAKE,
[AC_REQUIRE([AM_PROG_INSTALL])
PACKAGE=[$1]
AC_SUBST(PACKAGE)
AC_DEFINE_UNQUOTED(PACKAGE, "$PACKAGE")
VERSION=[$2]
AC_SUBST(VERSION)
AC_DEFINE_UNQUOTED(VERSION, "$VERSION")
AM_SANITY_CHECK
AC_ARG_PROGRAM
AC_PROG_MAKE_SET])


# serial 1

AC_DEFUN(AM_PROG_INSTALL,
[AC_REQUIRE([AC_PROG_INSTALL])
test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL_PROGRAM}'
AC_SUBST(INSTALL_SCRIPT)dnl
])

#
# Check to make sure that the build environment is sane.
#

AC_DEFUN(AM_SANITY_CHECK,
[AC_MSG_CHECKING([whether build environment is sane])
echo timestamp > conftestfile
# Do this in a subshell so we don't clobber the current shell's
# arguments.  FIXME: maybe try `-L' hack like GETLOADAVG test?
if (set X `ls -t $srcdir/configure conftestfile`; test "[$]2" = conftestfile)
then
   # Ok.
   :
else
   AC_MSG_ERROR([newly created file is older than distributed files!
Check your system clock])
fi
rm -f conftest*
AC_MSG_RESULT(yes)])

dnl
dnl CY_AC_WITH_THREADS determines which thread library the user intends
dnl to put underneath guile.  Pass it the path to find the guile top-level
dnl source directory.  Eg CY_AC_WITH_THREADS(../..) for tcl/unix.
dnl

AC_DEFUN([CY_AC_WITH_THREADS],[
AC_CACHE_CHECK("threads package type",cy_cv_threads_package,[
AC_CACHE_VAL(cy_cv_threads_cflags,[
AC_CACHE_VAL(cy_cv_threads_libs,[
use_threads=no;
AC_ARG_WITH(threads,[  --with-threads          thread interface],
            use_threads=$withval, use_threads=no)
test -n "$use_threads" || use_threads=qt
threads_package=unknown
if test "$use_threads" != no; then
dnl
dnl Test for the qt threads package - used for cooperative threads
dnl This may not necessarily be built yet - so just check for the
dnl header files.
dnl
  if test "$use_threads" = yes || test "$use_threads" = qt; then
     # Look for qt in source directory.  This is a hack: we look in
     # "./qt" because this check might be run at the top level.
     if test -f $srcdir/../qt/qt.c || test -f $srcdir/qt/qt.c; then
	threads_package=COOP
	cy_cv_threads_cflags="-I$srcdir/../qt -I../qt"
	cy_cv_threads_libs="../threads/libthreads.a ../qt/libqt.a"
     fi
  else
     if test -f $use_threads/qt.c; then
	# FIXME seems as though we should try to use an installed qt here.
	threads_package=COOP
	cy_cv_threads_cflags="-I$use_threads -I../qt"
	cy_cv_threads_libs="../threads/libthreads.a ../qt/libqt.a"
     fi
  fi
  if test "$use_threads" = pthreads; then
     # Look for pthreads in srcdir.  See above to understand why
     # we always set threads_package.
     if test -f $srcdir/../../pthreads/pthreads/queue.c \
	  || test -f $srcdir/../pthreads/pthreads/queue.c; then
	threads_package=MIT
	cy_cv_threads_cflags="-I$srcdir/../../pthreads/include"
	cy_cv_threads_libs="-L../../pthreads/lib -lpthread"
     fi
  fi
  saved_CPP="$CPPFLAGS"
  saved_LD="$LDFLAGS"
  saved_LIBS="$LIBS"
  if test "$threads_package" = unknown; then
dnl
dnl Test for the FSU threads package
dnl
    CPPFLAGS="-I$use_threads/include"
    LDFLAGS="-L$use_threads/lib"
    LIBS="-lgthreads -lmalloc"
    AC_TRY_LINK([#include <pthread.h>],[
pthread_equal(NULL,NULL);
], threads_package=FSU)
  fi
  if test "$threads_package" = unknown; then
dnl
dnl Test for the MIT threads package
dnl
    LIBS="-lpthread"
    AC_TRY_LINK([#include <pthread.h>],[
pthread_equal(NULL,NULL);
], threads_package=MIT)
  fi
  if test "$threads_package" = unknown; then
dnl
dnl Test for the PCthreads package
dnl
    LIBS="-lpthreads"
    AC_TRY_LINK([#include <pthread.h>],[
pthread_equal(NULL,NULL);
], threads_package=PCthreads)
  fi
dnl
dnl Set the appropriate flags!
dnl 
  cy_cv_threads_cflags="$CPPFLAGS $cy_cv_threads_cflags"
  cy_cv_threads_libs="$LDFLAGS $LIBS $cy_cv_threads_libs"
  cy_cv_threads_package=$threads_package
  CPPFLAGS="$saved_CPP"
  LDFLAGS="$saved_LD"
  LIBS="$saved_LIBS"
  if test "$threads_package" = unknown; then
    AC_MSG_ERROR("cannot find thread library installation")
  fi
fi
])
])
],
dnl
dnl Set flags according to what is cached.
dnl
CPPFLAGS="$cy_cv_threads_cflags"
LIBS="$cy_cv_threads_libs"
)
])

