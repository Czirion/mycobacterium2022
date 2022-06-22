## Download, exploration and metadate generation script

#Usage:
# Locate yourself in the global project folder where the scripts/download_explore.sh is located
# bash scripts/download_and_metadata.sh <date(only numbers)>

#Requisites:
# - Have Quast installed
# - Have R installed
# - Put the quast_a_metadatos.R script in the scripts/ folder

#Download Mycobacterium tuberculosis variant africanum in genebank and fasta format
ncbi-genome-download -P -r 3 -F "fasta,genbank" --genera "Mycobacterium tuberculosis variant africanum" bacteria

# Change foldername
echo "Renaming refseq/"
mv refseq/ refseq_"$1"

#Decompress
echo "Decompressing files"
gunzip refseq_"$1"/bacteria/GCF_*/*.gz

#Print the name of every genome
#WARNING: Some genomes may have extra strings like ", complete genome" along the complete name

grep "DEFINITION" refseq_"$1"/bacteria/GCF_*/*gbff | uniq | while read line
	do 
		assembly=$(echo $line | cut -d'/' -f3)
		taxonomy=$(echo $line | cut -d'/' -f4| cut -d' ' -f1 --complement)
		echo $assembly $taxonomy
	done > nombre.txt


#Run Quast
echo "Running Quast"
quast -o quast/ --space-efficient refseq_"$1"/bacteria/GCF_*/*.fna

#Run quast_to_metadata.tsv
echo "Creating metadata table"
Rscript scripts/quast_a_metadatos.R

#Print name of file with 
#for folder in GCF*
#	do
#		filename=$(echo $folder/*.gbff)
#		total_genes=$(grep "Genes (total)" $folder/*gbff | grep "Pseudo" -v | uniq | cut -d':' -f4)
#		echo $filename $total_genes
#	done | cut -d'/' -f2
#	 Genes (total)                     :: 4,107
#            CDSs (total)                      :: 4,056
#           Genes (coding)                    :: 3,851
#            CDSs (with protein)
#
#            Genes (total) :: 4,097
