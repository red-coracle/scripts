from distutils.core import setup
from Cython.Build import cythonize


setup(name='Luhn checksum validator', ext_modules=cythonize('luhn_cython.pyx', compiler_directives={"language_level": "3"}))
