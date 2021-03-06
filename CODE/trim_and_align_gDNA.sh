
#!/bin/sh

#----- Update the following varibles
bowtie_indexes="/data/theia/analysis/dm3/Sequence/bowtie_indexes/genome"
TRIMMOMATIC_DIR="/home/reazur/SOFTWARE"
#TRIBE_DIR="/data/theia/reazur/editing/github/TRIBE/CODE"

#---------------------

file=$1
prefix=${file%.fastq*}
trim_input=$file
trim_outfile=$prefix.trim.fastq 
avgquality="30"

#--------IMPORTATNT------#
#trim the library as needed, here we are trimming the first 6 and last six base of reads that that 50 base long. The parameter for Trimmomatics needs to be adjusted based on the quality of the reads and length of the read
java -jar $TRIMMOMATIC_DIR/Trimmomatic-0.30/trimmomatic-0.30.jar SE -phred33 $trim_input $trim_outfile CROP:45 HEADCROP:6 LEADING:25 TRAILING:25 AVGQUAL:$avgquality MINLEN:19


input=$trim_outfile
bowtie2_out=$prefix"_unfilterrm.sam"
bowtie2 --sensitive -p 9 -x $bowtie_indexes -U $input -S $bowtie2_out
samtools view -Sh -q 10 $bowtie2_out >$prefix".sam"
rm $bowtie2_out


#following code tested with samtools 1.3.1, you might have to tweak it a bit bases your installed verison of samtools (these flags can be problematic for older version of samtools: -@, -o)
samtools view -@ 6 -bSh  $prefix".sam" >  $prefix".bam"

sort_out=$prefix".sort.bam"
samtools sort -@ 6 $prefix".bam" -o $sort_out

samtools view -@ 4 -h $sort_out > $prefix".sort.sam"

rm $prefix".sam"
rm $prefix".bam"
