
#ifndef LIBFACTER_EXPORT_H
#define LIBFACTER_EXPORT_H

#ifdef LIBFACTER_STATIC_DEFINE
#  define LIBFACTER_EXPORT
#  define LIBFACTER_NO_EXPORT
#else
#  ifndef LIBFACTER_EXPORT
#    ifdef libfacter_EXPORTS
        /* We are building this library */
#      define LIBFACTER_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define LIBFACTER_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef LIBFACTER_NO_EXPORT
#    define LIBFACTER_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef LIBFACTER_DEPRECATED
#  define LIBFACTER_DEPRECATED 
#endif

#ifndef LIBFACTER_DEPRECATED_EXPORT
#  define LIBFACTER_DEPRECATED_EXPORT LIBFACTER_EXPORT LIBFACTER_DEPRECATED
#endif

#ifndef LIBFACTER_DEPRECATED_NO_EXPORT
#  define LIBFACTER_DEPRECATED_NO_EXPORT LIBFACTER_NO_EXPORT LIBFACTER_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define LIBFACTER_NO_DEPRECATED
#endif

#endif
