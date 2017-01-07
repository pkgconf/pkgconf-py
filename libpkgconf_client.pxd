from libc.stdio cimport FILE
from libcpp cimport bool
from libpkgconf_iter cimport *

ctypedef pkgconf_client_ pkgconf_client_t
ctypedef bool (*pkgconf_error_handler_func_t)(const char *msg, const pkgconf_client_t *client, const void *data)

cdef extern from "libpkgconf/libpkgconf.h":
    struct pkgconf_client_:
        pkgconf_list_t dir_list
        pkgconf_list_t pkg_cache
        pkgconf_list_t filter_libdirs
        pkgconf_list_t filter_includedirs
        pkgconf_list_t global_vars

        void *error_handler_data
        pkgconf_error_handler_func_t error_handler

        FILE *auditf

        char *sysroot_dir
        char *buildroot_dir

cdef extern from "libpkgconf/libpkgconf.h":
    void pkgconf_client_init(pkgconf_client_t *client, pkgconf_error_handler_func_t error_handler, void *error_handler_data)
    pkgconf_client_t *pkgconf_client_new(pkgconf_error_handler_func_t error_handler, void *error_handler_data)
    void pkgconf_client_deinit(pkgconf_client_t *client)
    void pkgconf_client_free(pkgconf_client_t *client)
    const char *pkgconf_client_get_sysroot_dir(const pkgconf_client_t *client)
    void pkgconf_client_set_sysroot_dir(pkgconf_client_t *client, const char *sysroot_dir)
    const char *pkgconf_client_get_buildroot_dir(const pkgconf_client_t *client)
    void pkgconf_client_set_buildroot_dir(pkgconf_client_t *client, const char *buildroot_dir)
    void pkgconf_pkg_dir_list_build(pkgconf_client_t *client, unsigned int flags)

