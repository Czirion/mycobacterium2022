# Mycobacterium 2022

Description and code of the Mycobacterium 2022 project

Requisites:
- R version 4.2.0
- Quast v5.0.2
- ncbi-genome-download version 0.3.1
- FIXME :anger:

## Genome download 

The first step is to download genomes in bulk from the NCBI using the `ncbi-genome-download` software using the following code:

~~~
ncbi-genome-download -P -r 3 -F "fasta,genbank" --genera "Mycobacterium tuberculosis" bacteria
~~~
{: .language-bash}

The `-P` flag is used to show a progress bar while the program is running. 
The `-r 3` option specifies to try every genome download 3 times in case the conection with NCBI is interrupted.  
The `-F "fasta,genbank"` options specifies the formats to download.  
The `--genera "Mycobacterium tuberculosis" bacteria` options specifies which genomes will be downloaded.  
The `--dry-run` flag can be used to know which genomes will be downloaded prior to running the download itself.  

## Creation of metadata table

Next run the script `metadata_generation.sh`:

~~~
bash metadata_generation.sh mt 220622
~~~
{: .language-bash}

This script runs QUAST on the `.fna.gz` and extracts parameters  
from the QUAST results and from the `.gbff` files to create a metadata table.  

It is used with the following positional arguments:  
1: Lineage abreviation to use in folder name  
2: Date of running to use in folder name  

The output is the file `metadata.tsv` within the `mt_220622/` directory. 
