from libcpp cimport bool
from libpkgconf_iter cimport *
from libpkgconf_client cimport *

ctypedef pkgconf_path_ pkgconf_path_t
cdef extern from "libpkgconf/libpkgconf.h":
    struct pkgconf_path_:
        pkgconf_node_t lnode
        char *path
        void *handle_path
        void *handle_device

    void pkgconf_path_add(const char *text, pkgconf_list_t *dirlist, bool filter)
    size_t pkgconf_path_split(const char *text, pkgconf_list_t *dirlist, bool filter)
    size_t pkgconf_path_build_from_environ(const char *environ, const char *fallback, pkgconf_list_t *dirlist, bool filter)
    bool pkgconf_path_match_list(const char *path, const pkgconf_list_t *dirlist)
    void pkgconf_path_free(pkgconf_list_t *dirlist)
