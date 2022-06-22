## Download, exploration and metadate generation script

#Usage:
# Locate yourself in the global project folder where the scripts/download_explore.sh is located
# bash scripts/download_and_metadata.sh arguments
# Positional arguments:
# 1: species abreviation for foldername
# 2: date in only numbers
# 3: formats to download (coma separated without spaces) surrounded by double ticks
# 4: lineaje name for NCBI download surrounded by double ticks

#Requisites:
# - Have Quast installed
# - Have R installed
# - Put the quast_a_metadatos.R script in the scripts/ folder

#Download Mycobacterium tuberculosis variant africanum in genebank and fasta format


ncbi-genome-download -P -r 3 -F "$3" --genera "$4" bacteria

# Change foldername
echo "Renaming folders"
mv refseq/ "$1"_"$2"/
mv "$1"_"$2"/bacteria/ "$1"_"$2"/raw_data/


#Decompress
echo "Decompressing files"
gunzip "$1"_"$2"/raw_data/GCF_*/*.gz

cd "$1"_"$2"/

#Create a table with all the needed parameters taken from the gbff
#The DEFINITION field has the name of the organism (Genus species variand strain) but sometimes also includes extra information about the sequence, like ",complete genome"
echo "Extracting parameters from data"
echo -e "Assembly""\t"Definition"\t"GenesTotal"\t"CDSsTotal"\t"GenesCoding"\t""CDSsProtein" > gbk_parameters.tsv

ls raw_data/GCF_*/*.gbff | while read line;
do 
assembly=$(echo $line | cut -d'/' -f2);
taxonomy=$(grep "DEFINITION" $line | uniq | cut -d' ' -f1,2 --complement)
total_genes=$(grep "Genes (total)" $line | grep "Pseudo" -v | uniq | rev | cut -d' ' -f1 | rev);
total_cds=$(grep "CDSs (total)" $line | uniq | rev | cut -d' ' -f1 | rev );
coding_genes=$(grep "Genes (coding)" $line | uniq | rev | cut -d' ' -f1 | rev);
protein_cds=$(grep "CDSs (with protein)" $line | uniq | rev | cut -d' ' -f1 | rev);
echo -e $assembly"\t"$taxonomy"\t"$total_genes"\t"$total_cds"\t"$coding_genes"\t"$protein_cds >> gbk_parameters.tsv;
done


#Run Quast
echo "Running Quast"
quast -o quast/ --space-efficient raw_data/GCF_*/*.fna

#Run quast_to_metadata.tsv
echo "Creating metadata table"
Rscript ../scripts/crear_metadatos.R

#Remove gbk_parameters.tsv
rm gbk_parameters.tsv

