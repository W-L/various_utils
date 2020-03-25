# collection of python classes and functions



def unpickle(pickleDict):
    # transfer each object from a pickled dictionary to the global namespace
    names = pickleDict.keys()
    for n in names:
        globals()[n] = pickleDict[n]