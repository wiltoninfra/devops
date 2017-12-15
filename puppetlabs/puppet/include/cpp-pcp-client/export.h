
#ifndef LIBCPP_PCP_CLIENT_EXPORT_H
#define LIBCPP_PCP_CLIENT_EXPORT_H

#ifdef LIBCPP_PCP_CLIENT_STATIC_DEFINE
#  define LIBCPP_PCP_CLIENT_EXPORT
#  define LIBCPP_PCP_CLIENT_NO_EXPORT
#else
#  ifndef LIBCPP_PCP_CLIENT_EXPORT
#    ifdef libcpp_pcp_client_EXPORTS
        /* We are building this library */
#      define LIBCPP_PCP_CLIENT_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define LIBCPP_PCP_CLIENT_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef LIBCPP_PCP_CLIENT_NO_EXPORT
#    define LIBCPP_PCP_CLIENT_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef LIBCPP_PCP_CLIENT_DEPRECATED
#  define LIBCPP_PCP_CLIENT_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef LIBCPP_PCP_CLIENT_DEPRECATED_EXPORT
#  define LIBCPP_PCP_CLIENT_DEPRECATED_EXPORT LIBCPP_PCP_CLIENT_EXPORT LIBCPP_PCP_CLIENT_DEPRECATED
#endif

#ifndef LIBCPP_PCP_CLIENT_DEPRECATED_NO_EXPORT
#  define LIBCPP_PCP_CLIENT_DEPRECATED_NO_EXPORT LIBCPP_PCP_CLIENT_NO_EXPORT LIBCPP_PCP_CLIENT_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define LIBCPP_PCP_CLIENT_NO_DEPRECATED
#endif

#endif
