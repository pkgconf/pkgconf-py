cdef void pkgconf_node_insert(pkgconf_node_t *node, void *data, pkgconf_list_t *list):
    cdef pkgconf_node_t *tnode

    node.data = data
    if not list.head:
        list.head = node
        list.tail = node
        list.length = 1
        return

    tnode = list.head

    node.next = tnode
    tnode.prev = node

    list.head = node
    list.length += 1

cdef void pkgconf_node_insert_tail(pkgconf_node_t *node, void *data, pkgconf_list_t *list):
    cdef pkgconf_node_t *tnode

    node.data = data
    if not list.head:
        list.head = node
        list.tail = node
        list.length = 1
        return

    tnode = list.tail

    node.prev = tnode
    tnode.next = node

    list.tail = node
    list.length += 1

cdef void pkgconf_node_delete(pkgconf_node_t *node, pkgconf_list_t *list):
    list.length -= 1

    if not node.prev:
        list.head = node.next
    else:
        node.prev.next = node.next

    if not node.next:
        list.tail = node.prev
    else:
        node.next.prev = node.prev

