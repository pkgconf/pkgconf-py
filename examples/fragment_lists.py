from __future__ import print_function

import pkgconf

c = pkgconf.Client()
fl = pkgconf.FragmentList(c)

# what is considered a system directory?
print('client filter_libdirs: %r' % c.filter_libdirs)
print('client filter_includedirs: %r' % c.filter_includedirs)

# get a known system libdir/includedir
system_libdir = c.filter_libdirs[0]
system_includedir = c.filter_includedirs[0]

# fragment lists start empty
print('initial state: %r' % fl)

# add a fragment that will be filtered
frag1 = pkgconf.Fragment(c, 'I', system_includedir)

print('adding %r to the fragment list' % frag1)
fl.append(frag1)

print('current state: %r' % fl)

# add a fragment that will not be filtered
frag2 = pkgconf.Fragment(c, 'I', system_includedir + '/foo')

print('adding %r to the fragment list' % frag2)
fl.append(frag2)

print('current state: %r' % fl)

# add another fragment that will be filtered
frag3 = pkgconf.Fragment(c, 'L', system_libdir)

print('adding %r to the fragment list' % frag3)
fl.append(frag3)

print('current state: %r' % fl)

# add another fragment that will not be filtered
frag4 = pkgconf.Fragment(c, 'L', system_libdir + '/foo')

print('adding %r to the fragment list' % frag4)
fl.append(frag4)

print('current state: %r' % fl)

# a fragment list can be rendered by typecasting it to str
print('rendered: %s' % fl)

# a fragment list can be filtered, which produces a copy of the fragment list
# use a noop filter function to copy the list itself
print('original fragment list: 0x%x' % id(fl))

copy1 = fl.filter(lambda frag, flags: True)
print('copied fragment list 1: 0x%x' % id(copy1))
print('copied fragment list 1 state: %r' % copy1)
print('copied fragment list 1 rendered: %s' % copy1)

# lets filter out the system dirs like normal pkgconf CLI does
# the `has_system_dir` attribute detemines if a fragment has a system dir or not
copy2 = fl.filter(lambda frag, flags: not frag.has_system_dir)

print('copied fragment list 2: 0x%x' % id(copy2))
print('copied fragment list 2 state: %r' % copy2)
print('copied fragment list 2 rendered: %s' % copy2)

# filtering out the non-system dirs is just a matter of inverting the logic...
copy3 = fl.filter(lambda frag, flags: frag.has_system_dir)

print('copied fragment list 3: 0x%x' % id(copy3))
print('copied fragment list 3 state: %r' % copy3)
print('copied fragment list 3 rendered: %s' % copy3)
