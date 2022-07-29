# Exploration of assemblies from PATRIC

## Installation of Command Line PATRIC

:computer:
~~~
sudo apt-get install gdebi-core
sudo apt --fix-broken install
sudo gdebi patric-cli-1.039.deb
~~~
{: .language.bash}

## Download metadata

Download general metadata.  
:computer:
~~~
p3-all-genomes --eq "genome_name, Mycobacterium" | p3-get-genome-data --attr genome_name --attr sra_accession --attr assembly_accession --attr biosample_accession --attr contigs --attr collection_year --attr geographic_location --attr host_name --attr host_health --attr isolation_source > metadata.tbl
~~~
{: .language-bash}

Download metadatata about antibiotic resistance.  
:computer:
~~~
p3-all-genomes --eq "genome_name, Mycobacterium" | p3-get-genome-drugs --attr antibiotic --attr computational_method --attr evidence --attr laboratory_typing_method --attr laboratory_typing_method_version --attr laboratory_typing_platform --attr measurement --attr measurement_sign --attr measurement_unit --attr measurement_value --attr resistant_phenotype --attr source --attr taxon_id --attr testing_standard --attr testing_standard_year > drugs.tbl
~~~
{: .language-bash}

Go to the script patric_metadta.R to see the metadata exploration.
