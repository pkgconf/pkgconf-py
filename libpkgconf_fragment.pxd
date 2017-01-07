from libcpp cimport bool
from libpkgconf_iter cimport *
from libpkgconf_client cimport *

ctypedef pkgconf_fragment_ pkgconf_fragment_t
ctypedef bool (*pkgconf_fragment_filter_func_t)(const pkgconf_client_t *client, const pkgconf_fragment_t *frag, unsigned int flags)

cdef extern from "libpkgconf/libpkgconf.h":
    cdef struct pkgconf_fragment_:
        pkgconf_node_t iter
        char type
        char *data

    void pkgconf_fragment_parse(const pkgconf_client_t *client, pkgconf_list_t *list, pkgconf_list_t *vars, const char *value)
    void pkgconf_fragment_add(const pkgconf_client_t *client, pkgconf_list_t *list, const char *string)
    void pkgconf_fragment_copy(pkgconf_list_t *list, const pkgconf_fragment_t *base, unsigned int flags, bool is_private)
    void pkgconf_fragment_delete(pkgconf_list_t *list, pkgconf_fragment_t *node)
    void pkgconf_fragment_free(pkgconf_list_t *list)
    void pkgconf_fragment_filter(const pkgconf_client_t *client, pkgconf_list_t *dest, pkgconf_list_t *src, pkgconf_fragment_filter_func_t filter_func, unsigned int flags)
    size_t pkgconf_fragment_render_len(const pkgconf_list_t *list)
    void pkgconf_fragment_render_buf(const pkgconf_list_t *list, char *buf, size_t len)
    char *pkgconf_fragment_render(const pkgconf_list_t *list)
    bool pkgconf_fragment_has_system_dir(const pkgconf_client_t *client, const pkgconf_fragment_t *frag)
