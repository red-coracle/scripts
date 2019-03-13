A fast cython implementation of validating Luhn checksums


Install:

`python setup.py build_ext --inplace`


Use:
```python
>>> from luhn_cython import valid
>>> valid('534618613411236')
True
```


Benchmark:
```
Name           Iterations   Avg. Time
----           ----------   ---------
luhn           1000000      9405.8 ns
luhnmod10      1000000      5153.3 ns
luhn_cython    1000000       149.4 ns
```
