import line_profiler

lp = line_profiler.LineProfiler()

func = lp(func)

func()

lp.print_stats()