ctypedef pkgconf_node_ pkgconf_node_t
ctypedef pkgconf_list_ pkgconf_list_t

cdef extern from "libpkgconf/libpkgconf.h":
    struct pkgconf_node_:
        pkgconf_node_t *prev
        pkgconf_node_t *next
        void *data

    struct pkgconf_list_:
        pkgconf_node_t *head
        pkgconf_node_t *tail
        size_t length

cdef void pkgconf_node_insert(pkgconf_node_t *node, void *data, pkgconf_list_t *list)
cdef void pkgconf_node_insert_tail(pkgconf_node_t *node, void *data, pkgconf_list_t *list)
cdef void pkgconf_node_delete(pkgconf_node_t *node, pkgconf_list_t *list)
