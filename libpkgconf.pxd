from libc.stdio cimport FILE
from libcpp cimport bool
from libpkgconf_iter cimport *

cdef enum pkgconf_pkg_comparator_t:
    PKGCONF_CMP_NOT_EQUAL
    PKGCONF_CMP_ANY
    PKGCONF_CMP_LESS_THAN
    PKGCONF_CMP_LESS_THAN_EQUAL
    PKGCONF_CMP_EQUAL
    PKGCONF_CMP_GREATER_THAN
    PKGCONF_CMP_GREATER_THAN_EQUAL

cdef enum pkgconf_client_traits_t:
    NoFlags                         = 0x000
    SearchPrivate                   = 0x001
    EnvOnly                         = 0x002
    NoUninstalled                   = 0x004
    SkipRootVirtual                 = 0x008
    MergePrivateFragments           = 0x010
    SkipConflicts                   = 0x020
    NoCache                         = 0x040
    SkipErrors                      = 0x080
    SkipProvides                    = 0x200

#ctypedef bool (*pkgconf_pkg_iteration_func_t)(const pkgconf_pkg_t *pkg, void *data)
#ctypedef void (*pkgconf_pkg_traverse_func_t)(pkgconf_client_t *client, pkgconf_pkg_t *pkg, void *data, unsigned int flags)
#ctypedef bool (*pkgconf_queue_apply_func_t)(pkgconf_client_t *client, pkgconf_pkg_t *world, void *data, int maxdepth, unsigned int flags)

from libpkgconf_client cimport *
from libpkgconf_tuple cimport *
from libpkgconf_path cimport *

cdef extern from "libpkgconf/libpkgconf.h":
    int pkgconf_compare_version(const char *a, const char *b)
