# https://raw.githubusercontent.com/intel-isl/Open3D/master/python/setup.py
from setuptools import setup, find_packages
from distutils.sysconfig import get_python_lib
import glob
import os
import sys
import subprocess

# Force platform specific wheel
try:
    from wheel.bdist_wheel import bdist_wheel as _bdist_wheel
    # https://stackoverflow.com/a/45150383/1255535
    class bdist_wheel(_bdist_wheel):
        def finalize_options(self):
            _bdist_wheel.finalize_options(self)
            self.root_is_pure = False
except ImportError:
    print(
        'Warning: cannot import "wheel" package to build platform-specific wheel'
    )
    print('Install the "wheel" package to fix this warning')
    bdist_wheel = None

cmdclass = {'bdist_wheel': bdist_wheel} if bdist_wheel is not None else dict()

so_files = []
so_files += glob.glob('@PROJECT_NAME@/*.so*') # linux, mac
so_files += glob.glob('@PROJECT_NAME@/*.pyd*') # windows
so_files += glob.glob('@PROJECT_NAME@/*.dll*') # windows
so_files = sorted(set(so_files))
so_files = [os.path.basename(s) for s in so_files]

home_url = '@PROJECT_HOME_URL@'

setup(
    author='@PROJECT_AUTHOR@',
    author_email='@PROJECT_AUTHOR_EMAIL@',
    classifiers=[
        # https://pypi.org/pypi?%3Aaction=list_classifiers
        'Development Status :: 3 - Alpha',
        'Environment :: X11 Applications',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: C++',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Topic :: Scientific/Engineering',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities',
    ],
    description=['''@PROJECT_DESCRIPTION@'''],
    install_requires=[],
    keywords=(),
    long_description='''@PROJECT_DESCRIPTION@''',
    name='@PROJECT_NAME@',
    packages=[
        '@PROJECT_NAME@',
    ],
    cmdclass=cmdclass,
    # https://setuptools.readthedocs.io/en/latest/setuptools.html?highlight=bdist_wheel#including-data-files
    include_package_data=True,
    package_data={
        '@PROJECT_NAME@': so_files,
    },
    url=home_url,
    project_urls={
        'Documentation': home_url,
        'Source code': home_url,
        'Issues': home_url,
    },
    version='@VERSION_FULL@',
    zip_safe=False,
)
