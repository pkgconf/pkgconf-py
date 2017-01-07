from libpkgconf_iter cimport *
from libpkgconf_client cimport *

cdef enum pkgconf_pkg_comparator_:
    PKGCONF_CMP_NOT_EQUAL
    PKGCONF_CMP_ANY
    PKGCONF_CMP_LESS_THAN
    PKGCONF_CMP_LESS_THAN_EQUAL
    PKGCONF_CMP_EQUAL
    PKGCONF_CMP_GREATER_THAN
    PKGCONF_CMP_GREATER_THAN_EQUAL

ctypedef pkgconf_pkg_comparator_ pkgconf_pkg_comparator_t

ctypedef pkgconf_dependency_ pkgconf_dependency_t
ctypedef pkgconf_pkg_ pkgconf_pkg_t
ctypedef bool (*pkgconf_pkg_iteration_func_t)(const pkgconf_pkg_t *pkg, void *data)
ctypedef void (*pkgconf_pkg_traverse_func_t)(pkgconf_client_t *client, pkgconf_pkg_t *pkg, void *data, unsigned int flags)

cdef extern from "libpkgconf/libpkgconf.h":
    struct pkgconf_dependency_:
        pkgconf_node_t iter

        char *package
        pkgconf_pkg_comparator_t compare
        char *version
        pkgconf_pkg_t *parent

    struct pkgconf_pkg_:
        pkgconf_node_t cache_iter

        int refcount
        char *id
        char *filename
        char *realname
        char *version
        char *description
        char *url
        char *pc_filedir

        pkgconf_list_t libs
        pkgconf_list_t libs_private
        pkgconf_list_t cflags
        pkgconf_list_t cflags_private

        pkgconf_list_t requires
        pkgconf_list_t requires_private
        pkgconf_list_t conflicts
        pkgconf_list_t provides

        pkgconf_list_t vars

        unsigned int flags

    pkgconf_pkg_t *pkgconf_pkg_ref(const pkgconf_client_t *client, pkgconf_pkg_t *pkg)
    void pkgconf_pkg_unref(pkgconf_client_t *client, pkgconf_pkg_t *pkg)
    void pkgconf_pkg_free(pkgconf_client_t *client, pkgconf_pkg_t *pkg)
    pkgconf_pkg_t *pkgconf_pkg_find(pkgconf_client_t *client, const char *name, unsigned int flags)
    unsigned int pkgconf_pkg_traverse(pkgconf_client_t *client, pkgconf_pkg_t *root, pkgconf_pkg_traverse_func_t func, void *data, int maxdepth, unsigned int flags)
    unsigned int pkgconf_pkg_verify_graph(pkgconf_client_t *client, pkgconf_pkg_t *root, int depth, unsigned int flags)
    pkgconf_pkg_t *pkgconf_pkg_verify_dependency(pkgconf_client_t *client, pkgconf_dependency_t *pkgdep, unsigned int flags, unsigned int *eflags)
    const char *pkgconf_pkg_get_comparator(const pkgconf_dependency_t *pkgdep)
    unsigned int pkgconf_pkg_cflags(pkgconf_client_t *client, pkgconf_pkg_t *root, pkgconf_list_t *list, int maxdepth, unsigned int flags)
    unsigned int pkgconf_pkg_libs(pkgconf_client_t *client, pkgconf_pkg_t *root, pkgconf_list_t *list, int maxdepth, unsigned int flags)
    pkgconf_pkg_comparator_t pkgconf_pkg_comparator_lookup_by_name(const char *name)
    pkgconf_pkg_t *pkgconf_builtin_pkg_get(const char *name)
