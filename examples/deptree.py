import pkgconf
import sys

cli = pkgconf.Client()
queue = cli.queue()

depth = 0

def print_package(package, private=False):
    global depth

    print('    ' * depth + package.name, '[private]' if private else '')
    depth += 1
    [print_package(child.resolve()) for child in package.requires]
    [print_package(child.resolve(), True) for child in package.requires_private]
    depth -= 1

if len(sys.argv) < 2:
    print('usage: deptree <package> [package]')
    exit()

[queue.push(i) for i in sys.argv[1:]]
queue.apply(lambda client, root, maxdepth, traits: print_package(root))
