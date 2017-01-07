import pkgconf
import sys

cli = pkgconf.Client()
queue = cli.queue()

depth = 0

def print_fraglist(package, name):
    global depth

    fraglist = getattr(package, name, [])
    if fraglist:
        print('%s%s: %r' % ('    ' * depth, name, list(fraglist)))

def print_package(package):
    global depth

    print('%s%s:' % ('    ' * depth, package.name))
    depth += 1

    [print_fraglist(package, fn) for fn in ['cflags', 'cflags_private', 'libs', 'libs_private']]

    if package.requires:
        print('%sRequires:' % ('    ' * depth))
        depth += 1
        [print_package(child.resolve()) for child in package.requires]
        depth -= 1

    depth -= 1

if len(sys.argv) < 2:
    print('usage: deptree <package> [package]')
    exit()

[queue.push(i) for i in sys.argv[1:]]
queue.apply(lambda client, root, maxdepth, traits: print_package(root))
