# Mycobacterium 2022

Description and code of the Mycobacterium 2022 project

## Installation and requirements

### Creation of Conda environment for data downloading (13/07/22)

Add the ncbi-genome-download for assemblies, the sra-tools for reads and biopython to be able to 
use the  `biosample2table.py` program.

~~~
conda create --name downloads_ncbi ncbi-genome-download sra-tools biopython
~~~
{: .language-bash}

Versions downloaded:
- ncbi-genome-download 0.3.1
- sra-tools 2.11.0

### Add `biosample2table.py` program

**Copied script** from its [GitHub repo](https://github.com/stajichlab/biosample_metadata/blob/main/scripts/biosample2table.py)
to `ncbi_mtb_genomes/scripts` and **added executing permission**:
~~~
chmod +x ncbi_mtb_genomes/scripts/biosample2table.py
~~~
{: .language-bash}


## Genome download 

The first step is to **download genomes** in bulk from the NCBI using the `ncbi-genome-download` software using the following code:

~~~
ncbi-genome-download -P -r 3 -p 8 -m assembly_metadata.tsv -F "fasta,genbank" --genera "Mycobacterium tuberculosis" bacteria
~~~
{: .language-bash}

The `-P` flag is used to show a progress bar while the program is running. 
The `-r 3` option specifies to try every genome download 3 times in case the conection with NCBI is interrupted.  
The `-p 8` option is to run parallel downloads in 8 threads.  
The `-m assembly_metadata.tsv` option is to generate a metadata table named `assembly_metadata.tsv`.  
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
