#! /bin/bash
#create a full pipline for rbb that just starts with the two genomes/proteomes and returns the rbb_hits


##EDIT
sp1=mimiv_genes
sp2=legpc_genes


reward=$((3))		#default 2
penalty=$((-2))	#default -3
gapopen=$((5))		#default 5
gapextend=$((5))	#default 2


#:<<'END'

#first rename all headers to unique identifiers and store a translation list

sp1_old_headers=$(cat $sp1 | grep ">")
ngene=$(echo "$sp1_old_headers" | wc -l)
IDs=$(eval echo A{00001..0$ngene})
sp1_new_headers=$(echo $IDs | tr " " "\n")
paste <(echo "$sp1_old_headers") <(echo "$sp1_new_headers") >${sp1}_headers
sp1_headers=$(paste <(echo "$sp1_old_headers") <(echo "$sp1_new_headers"))

:>${sp1}_new_headers

echo "$sp1_headers" | cut -f1 -d" " | while read header
do
	h=$(echo $header" ")
	cat $sp1 | sed -n -e /"$h"/,/'>'/p | head -n-1 >orig
	new_header=$(grep "$h" ${sp1}_headers | rev | cut -f1 | rev)
	new_header=$(echo ">"$new_header)
	sed s/">.*"/$new_header/ <orig >>${sp1}_new_headers
done


#also for second species
sp2_old_headers=$(cat $sp2 | grep ">")
ngene=$(echo "$sp2_old_headers" | wc -l)
IDs=$(eval echo B{00001..0$ngene})
sp2_new_headers=$(echo $IDs | tr " " "\n")
paste <(echo "$sp2_old_headers") <(echo "$sp2_new_headers") >${sp2}_headers
sp2_headers=$(paste <(echo "$sp2_old_headers") <(echo "$sp2_new_headers"))

:>${sp2}_new_headers

echo "$sp2_headers" | cut -f1 -d" " | while read header
do
	h=$(echo $header" ")
	cat $sp2 | sed -n -e /"$h"/,/'>'/p | head -n-1 >orig
	new_header=$(grep "$h" ${sp2}_headers | rev | cut -f1 | rev)
	new_header=$(echo ">"$new_header)
	sed s/">.*"/$new_header/ <orig >>${sp2}_new_headers
done

rm orig

echo "swapped headers"

#now we separate the genes into individual files with its headers as filenames

##EDIT
f1=${sp1}_new_headers
mkdir -p ${sp1}_sep

h=$(grep ">" $f1)

echo "$h" | while read i
do
	j=$(echo $i | tr -d ">")
	cat $f1 | sed -n -e /"$i"/,/'>'/p | head -n-1 > ${sp1}_sep/$j
done


#separate multifasta for the second spec
f2=${sp2}_new_headers
mkdir -p ${sp2}_sep

h=$(grep ">" $f2)

echo "$h" | while read i
do
	j=$(echo $i | tr -d ">")
	cat $f2 | sed -n -e /"$i"/,/'>'/p | head -n-1 > ${sp2}_sep/$j
done

echo "separated multifasta"

#now create the databases to blast against
makeblastdb -in $f1 -dbtype nucl -out ${sp1}_db
makeblastdb -in $f2 -dbtype nucl -out ${sp2}_db

mkdir -p ${sp1}_db ${sp2}_db
mv ${sp1}_db.* ${sp1}_db
mv ${sp2}_db.* ${sp2}_db

echo "created databases"

#END

#now blast sp1 against sp2 - and vice versa


:>${sp1}_vs_${sp2}
echo "query hit score eval ident pos gap" >>${sp1}_vs_${sp2}
dir=$(ls -d ${sp1}_sep/*)

for i in $dir
do
	j=$(basename $i)
	out=${sp1}_$j.blast
	/project/ngs_marsico/HGT/software/ncbi-blast-2.6.0+/bin/blastn -db ${sp2}_db/${sp2}_db -query $i -out $out -penalty $penalty -reward $reward -gapopen $gapopen -gapextend $gapextend
	
	qr=$(cat $out | grep -m1 "Query" | cut -f2 -d" ")
	hit=$(cat $out | grep -m1 "^>" | cut -f1-6 -d" " | cut -f2 -d" ")
	score=$(cat $out | grep -m1 "^ Score" | cut -f4 -d" ")
	ev=$(cat $out | grep -m1 "^ Score" | cut -f10 -d" " | tr -d ",")
	iden=$(cat $out | grep -m1 "^ Identities" | cut -f5 -d" " | tr -d "(%),")
	gap=$(cat $out | grep -m1 "^ Identities" | cut -f9 -d" "  | tr -d "(%),") #for blastp change this to pos, for blastn to gap
	pos=$((0)) #for blastn to retain the same amount of columns, for blastp comment out
	#gap=$(cat $out | grep -m1 "^ Identities" | cut -f13 -d" "  | tr -d "(%),") #for blastp to get extra entry, comm out for blastn
	
	echo $qr $hit $score $ev $iden $pos $gap >>${sp1}_vs_${sp2}
done

mkdir -p ${sp1}_blast
mv *.blast ${sp1}_blast


#vice versa blast
:>${sp2}_vs_${sp1}
echo "query hit score eval ident pos gap" >>${sp2}_vs_${sp1}
dir=$(ls -d ${sp2}_sep/*)

for i in $dir
do
	j=$(basename $i)
	out=${sp2}_$j.blast
	/project/ngs_marsico/HGT/software/ncbi-blast-2.6.0+/bin/blastn -db ${sp1}_db/${sp1}_db -query $i -out $out -penalty $penalty -reward $reward -gapopen $gapopen -gapextend $gapextend
	
	qr=$(cat $out | grep -m1 "Query" | cut -f2 -d" ")
	hit=$(cat $out | grep -m1 "^>" | cut -f1-6 -d" " | cut -f2 -d" ")
	score=$(cat $out | grep -m1 "^ Score" | cut -f4 -d" ")
	ev=$(cat $out | grep -m1 "^ Score" | cut -f10 -d" " | tr -d ",")
	iden=$(cat $out | grep -m1 "^ Identities" | cut -f5 -d" " | tr -d "(%),")
	gap=$(cat $out | grep -m1 "^ Identities" | cut -f9 -d" "  | tr -d "(%),") #for blastp change this to pos, for blastn to gap
	pos=$((0)) #for blastn to retain the same amount of columns, for blastp comment out
	#gap=$(cat $out | grep -m1 "^ Identities" | cut -f13 -d" "  | tr -d "(%),") #for blastp to get extra entry, comm out for blastn
	
	echo $qr $hit $score $ev $iden $pos $gap >>${sp2}_vs_${sp1}
done

mkdir -p ${sp2}_blast
mv *.blast ${sp2}_blast

echo "finished blasting"


#now extract the reciprocal hits
:>${sp1}_pairs_rev
cat ${sp1}_vs_${sp2} | tail -n+2 | while read i
do
	q=$(echo $i | cut -f1 -d" ")
	h=$(echo $i | cut -f2 -d" ")
	rev_pair=$(echo $h $q)
	echo $rev_pair >>${sp1}_pairs_rev
done

:>${sp2}_pairs
cat ${sp2}_vs_${sp1} | tail -n+2 | while read i
do
	echo $i | cut -f1-2 -d" " >>${sp2}_pairs
done

:>rbb_hits

cat ${sp2}_pairs | while read j
do
	match=$(cat ${sp1}_pairs_rev | grep "$j")
	echo $match >>rbb_hits
done


cat rbb_hits | tr -s "\n" >rbb_hits_sq

:>rbb_table
cat rbb_hits_sq | tail -n+2 | while read k
do
	stats=$(cat ${sp2}_vs_${sp1} | grep "$k" | cut -f3-7 -d" ")
	echo $k $stats >>rbb_table
done

sed 's/ /:/' rbb_table >rbb_table_form

echo "reciprocal hits written to file"

#END
