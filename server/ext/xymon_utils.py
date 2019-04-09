# -*- coding: utf-8 -*-
import os
import time
import pickle

def cache(name, timeout):
    cache_file = os.path.join(
        os.environ.get('XYMONTMP', '/var/lib/xymon/tmp'),
        '%s.%s.cache' % (os.environ.get('MACHINEDOTS', '_'), name)
    )
    def cache_wrapper(func):
        def wrapper(*args, **kwargs):
            try:
                mtime = os.path.getmtime(cache_file)
            except OSError as e:
                mtime = 0
            # update cache
            if mtime < time.time() - timeout:
                ret = func(*args, **kwargs)
                with open(cache_file, 'wb') as f:
                    pickle.dump(ret, f)
                return ret
            # return from cache
            else:
                with open(cache_file, 'rb') as f:
                    return pickle.load(f)
        return wrapper
    return cache_wrapper
