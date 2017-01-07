from libcpp cimport bool
cimport libpkgconf


cdef void error_trampoline(const char *msg, const libpkgconf.pkgconf_client_t *client, void *error_data):
    (<object>error_data).handle_error(msg.decode('utf-8'))


cdef class PathIterator:
    cdef libpkgconf.pkgconf_node_t *iter

    def __repr__(self):
        return '<PathIterator: %r>' % ([x for x in self])

    def __iter__(self):
        return self

    def __next__(self):
        if not self.iter:
            raise StopIteration()

        po = <libpkgconf.pkgconf_path_t *> self.iter.data
        self.iter = self.iter.next

        return po.path.decode('utf-8')


cdef class PathProxy:
    """A python list-like object that maps to a list of paths."""
    cdef libpkgconf.pkgconf_list_t *wrapped

    def __len__(self):
        return self.wrapped.length

    def __iter__(self):
        pi = PathIterator()
        pi.iter = self.wrapped.head
        return pi

    def __repr__(self):
        return repr([path for path in self])

    def __contains__(self, path):
        return libpkgconf.pkgconf_path_match_list(path.encode('utf-8'), self.wrapped)

    def __getitem__(self, idx):
        return list(self)[idx]

    def append(self, str path, bool filter):
        return libpkgconf.pkgconf_path_add(path.encode('utf-8'), self.wrapped, filter)


cdef class TupleIterator:
    cdef libpkgconf.pkgconf_node_t *iter

    def __repr__(self):
        return '<TupleIterator: %r>' % ([x for x in self])

    def __iter__(self):
        return self

    def __next__(self):
        if not self.iter:
            raise StopIteration()

        tuple = <libpkgconf.pkgconf_tuple_t *> self.iter.data
        self.iter = self.iter.next

        return (tuple.key.decode('utf-8'), tuple.value.decode('utf-8'))


cdef class TupleProxy:
    """A python dictionary-like object that maps to a list of key-value tuples."""
    cdef libpkgconf.pkgconf_list_t *wrapped
    cdef libpkgconf.pkgconf_client_t *wrapped_client

    def __len__(self):
        return self.wrapped.length

    def __repr__(self):
        return repr({k: v for k, v in self.items()})

    def __iter__(self):
        ti = TupleIterator()
        ti.iter = self.wrapped.head
        return ti

    def __getitem__(self, key):
        cdef const char *value
        value = libpkgconf.pkgconf_tuple_find(self.wrapped_client, self.wrapped, key.encode('utf-8'))
        if value:
            return value.decode('utf-8')
        return None

    def __setitem__(self, key, value):
        libpkgconf.pkgconf_tuple_add(self.wrapped_client, self.wrapped, key.encode('utf-8'), value.encode('utf-8'), False)

    def __delitem__(self, key):
        cdef libpkgconf.pkgconf_node_t *iter
        cdef libpkgconf.pkgconf_tuple_t *tu

        key = key.encode('utf-8')
        iter = self.wrapped.head
        while iter:
            tu = <libpkgconf.pkgconf_tuple_t *> iter.data
            if tu.key == key:
                libpkgconf.pkgconf_tuple_free_entry(tu, self.wrapped)
                return
            iter = iter.next

    def __contains__(self, key):
        return self.__getitem__(key) is not None

    def items(self):
        return iter(self)


cdef wrap_tuple(libpkgconf.pkgconf_list_t *tuple, libpkgconf.pkgconf_client_t *client):
     td = TupleProxy()
     td.wrapped = tuple
     td.wrapped_client = client
     return td


cdef class Client:
    cdef libpkgconf.pkgconf_client_t pc_client

    def __init__(self, build_dir_list=True, env_only=False):
        libpkgconf.pkgconf_client_init(&self.pc_client, <libpkgconf.pkgconf_error_handler_func_t> error_trampoline, <void *> self)
        if build_dir_list:
            self.build_dir_list(env_only)

    def __dealloc__(self):
        libpkgconf.pkgconf_client_deinit(&self.pc_client)

    def handle_error(self, message):
        print(message)

    cdef wrap_path_list(self, libpkgconf.pkgconf_list_t *list):
        pp = PathProxy()
        pp.wrapped = list
        return pp

    @property
    def globals(self):
        return wrap_tuple(&self.pc_client.global_vars, &self.pc_client)

    @property
    def dir_list(self):
        return self.wrap_path_list(&self.pc_client.dir_list)

    def build_dir_list(self, env_only=False):
        flags = 0
        if env_only:
            flags |= libpkgconf.pkgconf_client_traits_t.EnvOnly

        return libpkgconf.pkgconf_pkg_dir_list_build(&self.pc_client, flags)

    @property
    def filter_libdirs(self):
        return self.wrap_path_list(&self.pc_client.filter_libdirs)

    @property
    def filter_includedirs(self):
        return self.wrap_path_list(&self.pc_client.filter_includedirs)


def compare_version(a, b):
    """Compare two versions for equality.

    :param str a:
        The first version to compare.

    :param str b:
        The second version to compare.

    :returns:
        -1 if the first version is less than the second version,
        0 if both versions are equal,
        1 if the second version is less than the first version.
    """
    return libpkgconf.pkgconf_compare_version(a.encode('utf-8'), b.encode('utf-8'))
