import os
import subprocess
import sys

from Cython.Build import cythonize
from setuptools import setup, Extension


VERSION = "0.1.0"
DEBUG = False


def pkgconfig(package, min_version='0'):
    flag_map = {"-I": "include_dirs", "-L": "library_dirs", "-l": "libraries"}
    kw = {}

    try:
        tokens = subprocess.check_output(["pkg-config", "--libs", "--cflags", '%s >= %s' % (package, min_version)],
                                         universal_newlines=True)
    except subprocess.CalledProcessError:
        return {}

    for token in tokens.split():
        if token[:2] in flag_map:
            kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
        else:
            kw.setdefault("extra_compile_args", []).append(token)

    return kw


flags = pkgconfig('libpkgconf')
if not flags:
    print('Could not locate libpkgconf, check the PKG_CONFIG_PATH environment variable or perhaps download it:')
    print('http://www.pkgconf.org/')
    exit()

if DEBUG:
    flags['define_macros'] = [('CYTHON_TRACE', '1')]

extensions = [Extension("pkgconf", ["pkgconf.pyx"], **flags)]

setup(
    name="pkgconf",
    version=VERSION,
    description="Python binding for libpkgconf",
    platforms=["Linux"],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: ISC License",
        "Operating System :: POSIX :: Linux",
        "Operating System :: POSIX :: BSD",
        "Programming Language :: Cython",
        "Programming Language :: C",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
    ],
    author="William Pitcock",
    author_email="nenolod@dereferenced.org",
    maintainer="William Pitcock",
    maintainer_email="nenolod@dereferenced.org",
    url="http://github.com/pkgconf/pkgconf-py",
    download_url="https://distfiles.dereferenced.org/pkgconf-py/pkgconf-py-%s.tar.gz" % VERSION,
    ext_modules=cythonize(extensions, gdb_debug=DEBUG),
    setup_requires=["Cython>=0.24.0"],
)
