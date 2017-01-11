import pkgconf

c = pkgconf.Client()

def print_package(pkg):
    print('%-30s - [%s] %s' % (pkg.name, pkg.realname, pkg.description))
    return False

c.scan_all(print_package)
