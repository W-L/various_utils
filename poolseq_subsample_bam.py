#!/usr/bin/env python3
# combining subsampled sam files

from collections import defaultdict
import subprocess


path = "/Volumes/Temp/Lukas"
#meta = open(path + "/consensus_te/data/meta_tables/gdl_table", 'r') #gdl
meta = open(path + "/consensus_te/data/meta_tables/dpgp/dpgp2", 'r') #dpgp2


def grouping(meta):
	groups = defaultdict(list)
	
	for line in meta:
		if line.startswith("shortID"):
			continue
		l = line.split(' ')
	
		#group_id = list(l[0])[0] #for gdl
		#srr = l[2] #gdl
		group_id = l[0][0:2] #for dpgp2
		srr = l[3] #dpgp2
		
		groups[group_id].append(srr)
	return(groups)
		
		
def merge(groups):
	files = list()
	for g in groups:
		g_file = open(g + ".sam", 'w+')
		
		srrs = list()
		srrs.append('cat')
		srrs.append(groups[g][0] + suffix + '.header')
		for s in groups[g]:
			srrs.append(s + suffix + '.sam.subsample')
			
		cmd = ' '.join(srrs)
		merge = subprocess.run(cmd, stdout=g_file, stderr=subprocess.PIPE, shell=True)
			
		g_file.close()
		files.append(g + ".sam")
	return(files)


suffix=".allte.sort.bam"

group_dict = grouping(meta)

file_list = merge(group_dict)
print(file_list)

meta.close()

