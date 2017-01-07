from libc.stdio cimport FILE
from libcpp cimport bool
from libpkgconf_iter cimport *

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

from libpkgconf_client cimport *
from libpkgconf_tuple cimport *
from libpkgconf_path cimport *
from libpkgconf_pkg cimport *

cdef extern from "libpkgconf/libpkgconf.h":
    int pkgconf_compare_version(const char *a, const char *b)
