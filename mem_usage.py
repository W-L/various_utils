#! /usr/bin/env python3

import os
import psutil

def mem_usage():
    process = psutil.Process(os.getpid())
    mem = process.memory_info().rss
    return('{0:.2f} {1}'.format(mem / (2**20), 'M'))



