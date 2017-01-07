# cython: c_string_type=unicode, c_string_encoding=utf8

from libc.stdlib cimport free
from libc.string cimport strdup
from libcpp cimport bool
cimport libpkgconf


cdef void error_trampoline(const char *msg, const libpkgconf.pkgconf_client_t *client, void *error_data):
    (<object>error_data).handle_error(<str> msg[0:-1])


cdef void traverse_trampoline(libpkgconf.pkgconf_client_t *client, libpkgconf.pkgconf_pkg_t *pkg, void *data, unsigned int flags):
    pr = PackageRef()
    pr.client = data[1]
    pr.parent = pkg
    (<object>data[0])(pr, flags)


resolver_errmap = {
    libpkgconf.resolver_err.NoError: 'no error',
    libpkgconf.resolver_err.PackageNotFound: 'package not found',
    libpkgconf.resolver_err.VersionMismatch: 'version mismatch',
    libpkgconf.resolver_err.PackageConflict: 'package conflicts with another package',
    libpkgconf.resolver_err.DependencyGraphBreak: 'dependency graph break',
}


comparator_map = {
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_NOT_EQUAL: '!=',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_ANY: '(any)',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_LESS_THAN: '<',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_LESS_THAN_EQUAL: '<=',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_EQUAL: '=',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_GREATER_THAN: '>',
    libpkgconf.pkgconf_pkg_comparator_t.PKGCONF_CMP_GREATER_THAN_EQUAL: '>=',
}


class ResolverError(Exception):
    def __init__(self, err):
        super().__init__(resolver_errmap.get(err, 'unknown error'))


cdef class FragmentIterator:
    cdef libpkgconf.pkgconf_node_t *iter

    def __iter__(self):
        return self

    def __next__(self):
        cdef libpkgconf.pkgconf_fragment_t *frag

        if not self.iter:
            raise StopIteration()

        iter = self.iter
        frag = <libpkgconf.pkgconf_fragment_t *> iter.data
        self.iter = iter.next

        return (chr(frag.type), <str> frag.data)


cdef class FragmentListRef:
    cdef libpkgconf.pkgconf_list_t *lst
    cdef Client client
    cdef PackageRef parent

    def __len__(self):
        return self.lst.length

    def __repr__(self):
        return repr([x for x in self])

    def __iter__(self):
        fi = FragmentIterator()
        fi.iter = self.lst.head
        return fi

    def __str__(self):
        rawbuf = libpkgconf.pkgconf_fragment_render(self.lst)
        buf = <str> rawbuf
        free(rawbuf)

        return buf


cdef class FragmentList(FragmentListRef):
    cdef libpkgconf.pkgconf_list_t fraglist

    def __cinit__(self):
        self.lst = &self.fraglist


cdef class DependencyRef:
    cdef libpkgconf.pkgconf_dependency_t *wrapped
    cdef Client client
    cdef PackageRef parent

    def __repr__(self):
        summary = "<DependencyRef: %s" % self.package
        if self.compare != libpkgconf.pkgconf_pkg_comparator_.PKGCONF_CMP_ANY:
            summary += " %s %s" % (comparator_map.get(self.compare, '???'), self.version)
        summary += ">"

    @property
    def package(self):
        if not self.wrapped.package:
            return None
        return <str> self.wrapped.package

    @property
    def compare(self):
        return self.wrapped.compare

    @property
    def version(self):
        if not self.wrapped.version:
            return None
        return <str> self.wrapped.version

    def resolve(self, traits=0):
        cdef libpkgconf.pkgconf_pkg_t *pkg
        cdef unsigned int eflags = 0

        pkg = libpkgconf.pkgconf_pkg_verify_dependency(&self.client.pc_client, self.wrapped, traits, &eflags)
        if not pkg:
            raise ResolverError(eflags)

        pr = PackageRef()
        pr.client = self.client
        pr.parent = pkg
        return pr


cdef class DependencyIterator:
    cdef Client client
    cdef PackageRef parent
    cdef libpkgconf.pkgconf_node_t *iter

    def __iter__(self):
        return self

    def __next__(self):
        if not self.iter:
            raise StopIteration()

        iter = self.iter
        dr = DependencyRef()
        dr.client = self.client
        dr.parent = self.parent
        dr.wrapped = <libpkgconf.pkgconf_dependency_t *> iter.data
        self.iter = iter.next

        return dr


cdef class DependencyList:
    cdef Client client
    cdef PackageRef parent
    cdef libpkgconf.pkgconf_list_t *lst

    def __len__(self):
        return self.lst.length

    def __iter__(self):
        di = DependencyIterator()
        di.client = self.client
        di.parent = self.parent
        di.iter = self.lst.head
        return di

    def __repr__(self):
        repr([x for x in self])


cdef class PackageRef:
    cdef libpkgconf.pkgconf_pkg_t *parent
    cdef Client client

    def __repr__(self):
        summary = "<PackageRef: %s" % self.name
        if self.version:
            summary += " [%s]" % self.version
        if self.refcount:
            summary += ", refcount=%d" % self.refcount
        summary += ">"
        return summary

    @property
    def refcount(self):
        return self.parent.refcount

    @property
    def name(self):
        if not self.parent.id:
            return None
        return <str> self.parent.id

    @property
    def filename(self):
        if not self.parent.filename:
            return None
        return <str> self.parent.filename

    @property
    def realname(self):
        if not self.parent.realname:
            return None
        return <str> self.parent.realname

    @property
    def version(self):
        if not self.parent.version:
            return None
        return <str> self.parent.version

    @property
    def description(self):
        if not self.parent.description:
            return None
        return <str> self.parent.description

    @property
    def url(self):
        if not self.parent.url:
            return None
        return <str> self.parent.url

    @property
    def flags(self):
        return self.parent.flags

    @property
    def vars(self):
        td = TupleProxy()
        td.wrapped = &self.parent.vars
        td.wrapped_client = &self.client.pc_client
        return td

    def traverse(self, callback, maxdepth=-1, traits=0):
        """Traverse all dependent children below this point in the graph, up to maxdepth levels."""
        passback = (callback, self.client)
        result = libpkgconf.pkgconf_pkg_traverse(&self.client.pc_client, self.parent, <libpkgconf.pkgconf_pkg_traverse_func_t> traverse_trampoline, <void *> passback, maxdepth, traits)
        if result:
            raise ResolverError(result)

    cdef fraglist(self, libpkgconf.pkgconf_list_t *lst):
        fl = FragmentListRef()
        fl.client = self.client
        fl.parent = self
        fl.lst = lst
        return fl

    @property
    def cflags(self):
        return self.fraglist(&self.parent.cflags)

    @property
    def cflags_private(self):
        return self.fraglist(&self.parent.cflags_private)

    @property
    def libs(self):
        return self.fraglist(&self.parent.libs)

    @property
    def libs_private(self):
        return self.fraglist(&self.parent.libs_private)

    cdef deplist(self, libpkgconf.pkgconf_list_t *lst):
        dl = DependencyList()
        dl.client = self.client
        dl.parent = self
        dl.lst = lst
        return dl

    @property
    def requires(self):
        return self.deplist(&self.parent.requires)

    @property
    def requires_private(self):
        return self.deplist(&self.parent.requires_private)

    @property
    def conflicts(self):
        return self.deplist(&self.parent.conflicts)

    @property
    def provides(self):
        return self.deplist(&self.parent.provides)


cdef class Package(PackageRef):
    cdef libpkgconf.pkgconf_pkg_t pkg

    def __cinit__(self, *args, **kwargs):
        self.parent = &self.pkg

    def __init__(self, name, realname, version=None, flags=libpkgconf.property_flags.Virtual):
        self.pkg.id = strdup(name.encode('utf-8'))
        self.pkg.realname = strdup(realname.encode('utf-8'))
        if version:
            self.pkg.version = strdup(version.encode('utf-8'))
        if flags:
            self.pkg.flags = flags


cdef class Queue:
    """A dependency resolution queue.

    This is the top level object of the dependency resolver.  The dependency resolution
    problem is pushed onto the queue, which is basically a stack of package dependencies.
    The dependency resolution problem is then compiled into a dependency graph, which provides
    the solution when traversed.
    """
    cdef libpkgconf.pkgconf_list_t qlist
    cdef libpkgconf.pkgconf_pkg_t world
    cdef Client client

    def __cinit__(self, client):
        self.world.id = b'virtual:world'
        self.world.realname = b'virtual world package'
        self.world.flags = libpkgconf.property_flags.Virtual

    def __init__(self, client):
        self.client = client

    def __del__(self):
        libpkgconf.pkgconf_pkg_free(&self.client.pc_client, &self.world)
        libpkgconf.pkgconf_queue_free(&self.qlist)

    def push(self, package):
        """Push a requested dependency onto the dependency resolver's queue.

        :param str package:
            The package dependency described as <package> [comparator [version]].
        """
        libpkgconf.pkgconf_queue_push(&self.qlist, package.encode('utf-8'))

    def validate(self, maxdepth=-1, traits=0):
        """Verifies a dependency resolution queue by attempting to solve it.
        Returns true if solvable, else throws ResolverError if an exception
        is encountered.

        :return: true if solvable
        """
        if not libpkgconf.pkgconf_queue_compile(&self.client.pc_client, &self.world, &self.qlist):
            raise ResolverError(libpkgconf.resolver_err.DependencyGraphBreak)

        result = libpkgconf.pkgconf_pkg_verify_graph(&self.client.pc_client, &self.world, maxdepth, traits)
        if result:
            raise ResolverError(result)

        return True

    def apply(self, callback, maxdepth=-1, traits=0):
        """Compiles a dependency resolution queue and pass the solution to a callback to begin
        traversal.  Throws ResolverError if an exception is encountered.
        """
        if not self.validate(maxdepth, traits):
            return

        root = PackageRef()
        root.client = self.client
        root.parent = &self.world

        callback(self.client, root, maxdepth, traits)


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

        return <str> po.path


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

        return (<str> tuple.key, <str> tuple.value)


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
            return <str> value
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

    def queue(self):
        """Creates a new dependency resolver attached to this client."""
        q = Queue(self)
        return q

    def lookup_package(self, name, traits=0):
        """Looks up a package and returns a Package reference."""
        cdef libpkgconf.pkgconf_pkg_t *pkg
        pkg = libpkgconf.pkgconf_pkg_find(&self.pc_client, name.encode('utf-8'), traits)
        if not pkg:
            return None
        pr = PackageRef()
        pr.parent = pkg
        pr.client = self
        return pr


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
