__author__ = 'mdenil'

import numpy as np

from cpu import space

class WordEmbedding(object):
    def __init__(self,
                 dimension,
                 vocabulary_size,
                 ):

        self.dimension = dimension
        self.vocabulary_size = vocabulary_size

        self.E = 0.05 * np.random.standard_normal(size=(self.vocabulary_size, self.dimension))

    def fprop(self, X, meta):
        working_space = meta['space_below']
        X, working_space = working_space.transform(X, ['bw', 'd'])

        X = self.E[X.ravel()]

        meta['space_above'] = working_space.with_extent(d=self.dimension)

        return X, meta

    def __repr__(self):
        return "{}(dim={}, vocab_size={})".format(
            self.__class__.__name__,
            self.dimension,
            self.vocabulary_size)
