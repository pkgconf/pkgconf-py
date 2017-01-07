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
