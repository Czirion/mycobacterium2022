# Mycobacterium 2022

Description and code of the Mycobacterium 2022 project

## Genome download and creation of metadata table

The script `download_and_metadata.sh` downloads genomes from the NCBI, runs QUAST on them and extracts parameters  
from the QUAST results and the `.gbff` files to create a metadate table.  
It is used with the following positional arguments:  
1: Lineage abreviation to use in folder name  
2: Date of running to use in folder name  
3: Formats to download from NCBI separated by commas without spaces and between `""`. Example: "fasta,genbank"  
4: Lineage name to use in NCBI download between `""`. Example: "Mycobacterium tuberculosis variant microti"  
