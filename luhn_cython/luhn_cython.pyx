import cython


# Cythonized version of https://github.com/luhnmod10/python
def valid(str number):
    """
    Returns true if the number string is luhn valid, and false otherwise.  The
    number string passed to the function must contain only numeric characters
    otherwise behavior is undefined.
    """
    cdef int checksum, offset, number_len, i, n, result

    checksum = 0

    number_len = len(number)
    offset = ord('0')

    i = number_len - 1
    while i >= 0:
        n = ord(number[i]) - offset
        checksum += n
        i -= 2

    i = number_len - 2
    while i >= 0:
        n = ord(number[i]) - offset
        n *= 2
        if n > 9:
            n -= 9
        checksum += n
        i -= 2

    return  checksum % 10 == 0
