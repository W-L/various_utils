#!/usr/bin/env python3

import argparse

def heterozygosity(deletions):
    # TE = locus, deletions = alleles
    # het = 1 - sum(d_i * d_i)
    delsum = 0.0
    het = 1.0
    for d in deletions:
        if d == 0.0:
            continue
        delsum += d
        het -= d ** 2
    if delsum > 1.0:
        raise Exception("sum of deletion frequencies not allowed to exceed 1.0")
    flfreq = 1.0 - delsum
    het -= flfreq ** 2  # also include the full length as a marker
    return(het)
    
    
def calcD(df1, df2):
    
    dft = [(f1 + f2) / 2.0 for f1, f2 in zip(df1, df2)]
    h1 = heterozygosity(df1)
    h2 = heterozygosity(df2)
    ht = heterozygosity(dft)
    
    hs = (h1 + h2) / 2.0
    
    D = ( (ht - hs) / (1 - hs) ) * (2 / (2 - 1))
    if D < 0.0 or D > 1.0:
        raise Exception("Invalid D")
    return(D)


parser = argparse.ArgumentParser()
parser.add_argument("--d1", type=str, required=True)
parser.add_argument("--d2", type=str, required=True)
parser.add_argument("--d3", type=str, required=True)
args = parser.parse_args()

demes = [[float(i) for i in args.d1.split(',')],
        [float(i) for i in args.d2.split(',')],
        [float(i) for i in args.d3.split(',')]]


dm = [[0.0, ] * len(demes) for i in range(0, len(demes))]


for i in range(0, len(demes)):
    for k in range(0, len(demes)):
        dist_D = calcD(demes[i], demes[k])
        dm[i][k] = dist_D
            
            
mat = open('matrix.D', 'w')
header = ['', '1', '2', '3']
mat.write(' '.join(header) + '\n')

for i in range(0, len(demes)):    
    li = [i+1] + dm[i]
    line = [str(k) for k in li]
    mat.write(' '.join(line) + '\n')
    
mat.close()        
