# Mycobacterium 2022

Description and code of the Mycobacterium 2022 project

## Installation and requirements

### Creation of Conda environment for data downloading (07/13/22)

Add the ncbi-genome-download for assemblies, the sra-tools for reads and biopython to be able to 
use the  `biosample2table.py` program.  
:zap:
~~~
conda create --name downloads_ncbi ncbi-genome-download sra-tools biopython
~~~
{: .language-bash}

Versions downloaded:
- ncbi-genome-download 0.3.1
- sra-tools 2.11.0

### Add `biosample2table.py` program

**Copy script** from its [GitHub repo](https://github.com/stajichlab/biosample_metadata/blob/main/scripts/biosample2table.py)
to `ncbi_mtb_genomes/scripts` and **add executing permission**:  
:zap:
~~~
chmod +x ncbi_mtb_genomes/scripts/biosample2table.py
~~~
{: .language-bash}


## Download of genome assemblies and metadata (07/13/22)

**Download genomes** in bulk from the NCBI using the `ncbi-genome-download` software using the following code:  
⚡ ⌛
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

The output will have the directories `refseq/bacteria/`and inside of it there will be a folder for each assembly. 
**Rename** `refseq/` for `ncbi_mtb_genomes/` and `bacteria/` for `raw_data/`. And **move the `assembly_metadata.tsv`** inside `ncbi_mtb_genomes`.

With the downloaded assemblies an `assembly_metadata.tsv` was generated.  
**Extract the BioSample** column from the metadata into a new file.  
⚡
~~~
cd ncbi_mtb_genomes/
cat assembly_metadata.tsv | cut -f3 | grep "biosample" -v | uniq > biosamples_list.txt
~~~
{: .language-bash}

## Download RunInfo of the SRA reads

Go to the [SRA page](https://www.ncbi.nlm.nih.gov/sra) and search "Mycobacterium tuberculosis".  
Apply the filters:
- Source: DNA
- Type: genome
- Layout: paired
- Platfrom: Illumina
- File type: fastq

Click on `Sent to` `File` `RunInfo`. This will download a file `SraRunInfo.csv` from which the BioSample numbers can be extracted.  
Make a folder `reads_mtb_sra/` and put the file there.

**Extract the BioSample** column  from `SraRunInfo.csv`:  
💻
IN PROCESS

**Upload** the `biosamples_list.txt` to the server.

## Metadata exploration of downloaded assembled genomes and SRA reads

### Get assembly parameters with QUAST for the downloaded assemblies

**Load environment** that has Quast installed. (Environment `metagenomics` was already available in the server).  
- Quast v5.0.2

:zap:
~~~
conda activate metagenomics
~~~
**Run Quast** in all nucelotide fastas:  
:zap:
~~~
quast -o quast/ --space-efficient raw_data/GCF_*/*.fna.gz
~~~

### Obtain BioSample metadata for both assemlies and SRA reads


**Obtain metadata from BioSamples** using `biosample2table.py`.  
⚡
~~~
cd ncbi_mtb_genomes/
../scripts/biosample2table.py --in biosamples_list.txt --out metadata_biosamples.tsv -e <user-email>
cd ../reads_mtb_sra/
../scripts/biosample2table.py --in biosamples_list.txt --out metadata_biosamples.tsv -e <user-email>
~~~
{: .language-bash}

**Download** both `metadata_biosamples.tsv` files to local computer. 

### Metadata cleaning in R
For the assemblies the metadata cleaning and exploration was performed with the R script: `filtrado_de_metadatos.R`

For the SRA reads the metadata cleaning and exploration was performed with the R script: `limpieza_metadatos.sra.R
`limpieza_metadatos_sra.R`
