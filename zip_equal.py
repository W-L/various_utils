def zip_equal(*iterables):
    # a version of zip that does not allow different length arguments
    sentinel = object()
    for combo in zip_longest(*iterables, fillvalue=sentinel):
        if sentinel in combo:
            raise ValueError('Arguments have different lengths')
        yield combo 
