cimport libpkgconf


cdef void error_trampoline(const char *msg, const libpkgconf.pkgconf_client_t *client, void *error_data):
    (<object>error_data).handle_error(msg.decode('utf-8'))


cdef class Client:
    cdef libpkgconf.pkgconf_client_t pc_client

    def __init__(self):
        libpkgconf.pkgconf_client_init(&self.pc_client, <libpkgconf.pkgconf_error_handler_func_t> error_trampoline, <void *> self)

    def __dealloc__(self):
        libpkgconf.pkgconf_client_deinit(&self.pc_client)

    def handle_error(self, message):
        print(message)


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
