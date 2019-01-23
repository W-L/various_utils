#! /bin/bash

bams=$(ls *.bam)

for b in $bams; do
	echo $b
	header="samtools view -H -o $b.header $b"
	sam="samtools view -o $b.sam $b"
	eval $header
	eval $sam
	echo ""
done

sams=$(ls *.sam)

for s in $sams; do
	echo $s
	shuf="gshuf -n 1000000 $s >$s.subsample"
	eval $shuf
	rm $s
	echo ""
done

exit 0