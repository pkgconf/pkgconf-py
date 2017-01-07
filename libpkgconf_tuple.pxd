from libcpp cimport bool
from libpkgconf_iter cimport *
from libpkgconf_client cimport *

ctypedef pkgconf_tuple_ pkgconf_tuple_t
cdef extern from "libpkgconf/libpkgconf.h":
    struct pkgconf_tuple_:
        pkgconf_node_t iter
        char *key
        char *value

    pkgconf_tuple_t *pkgconf_tuple_add(const pkgconf_client_t *client, pkgconf_list_t *parent, const char *key, const char *value, bool parse)
    char *pkgconf_tuple_find(const pkgconf_client_t *client, pkgconf_list_t *list, const char *key)
    char *pkgconf_tuple_parse(const pkgconf_client_t *client, pkgconf_list_t *list, const char *value)
    void pkgconf_tuple_free(pkgconf_list_t *list)
    void pkgconf_tuple_free_entry(pkgconf_tuple_t *tuple, pkgconf_list_t *list)
    void pkgconf_tuple_add_global(pkgconf_client_t *client, const char *key, const char *value)
    char *pkgconf_tuple_find_global(const pkgconf_client_t *client, const char *key)
    void pkgconf_tuple_free_global(pkgconf_client_t *client)
    void pkgconf_tuple_define_global(pkgconf_client_t *client, const char *kv)
