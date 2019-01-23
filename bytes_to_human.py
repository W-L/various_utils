#!/usr/bin/env python

def bytes2human(n):

    n = int(n)
    if n < 0:
        raise ValueError("n < 0")
    symbols = ('B', 'K', 'M', 'G', 'T')
    prefix = {}
    for i, s in enumerate(symbols[1:]):
        prefix[s] = 1 << (i+1)*10 # left bit shifts
    for symbol in reversed(symbols[1:]):
        if n >= prefix[symbol]: 
            value = float(n) / prefix[symbol] 
            return '{0[value]:.2f} {1}'.format(locals(), symbol)
    return '{0:.2f} {1}'.format(n, symbols[0])
