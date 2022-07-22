# WHO database

Here I will describe the process made to the `mmc2.xlsx` file obtained from [the publicaton](https://www.thelancet.com/journals/lanmic/article/PIIS2666-5247(21)00301-3/fulltext#supplementaryMaterial)
"The 2021 WHO catalogue of Mycobacterium tuberculosis complex mutations associated with drug resistance: a genotypic analysis".

First I made a little modification by hand on the column names of the `mmc2.xlsx` Excel file to be able to import it to R.
And then I used the script `who/obtain_run_id.R` script to do the following steps:

## Extract BioSample and SRA numbers to obtain metadata

Since not every observation (38,223 total) has an SRA run number and some have multiple SRA numbers, 
the original table was broken down into many tables in order to extract the BioSample or SRA number according to the data available.

### Table with complete information about Run, Experiment and BioSample and only one SRA Run per observation (22,155)

- `SRA_todos.txt` has only the SRA Runs and is used to obtain the metadta with:  
⚡
~~~
../scripts/biosample2table.py --in SRA_todos.txt --sra --out metadata_ids_todos.tsv -e <user-email>
~~~
{: .language-bash}

### Table with BioSample information in ena_run column (7,275)

- `biosample_runA.txt` has only the BioSamples and is used to obtain the metadta with:  
⚡
~~~
../scripts/biosample2table.py --in biosample_runA.txt --out metadata_biosam_ids_runA.tsv -e <user-email>
~~~
{: .language-bash}

## All lists

- `SRA_todos.txt` : List of SRA runs. Where there is only one run number and all other codes (project, sample and axperiment) are present. 22,155 
- `SRA_runA.txt`: List of SRA runs. Where there is only one run number and not all other codes are present. 7,275
- `SRA_runAB.tsv`: Lists of SRA runs where all observations have two run numbers. (This table has a lot of observations with repeated run numbers) 159
- `SRA_runABC.tsv`: Lists of SRA runs where all observations have three run numbers. 2
- `SRA_runABCD.tsv`: Lists of SRA runs where all observations have four run numbers. 74
- `biosample_runA.txt`: List of BioSamples. Where the BioSample code was in the `ena_run` column and there is only one BioSample. 7,275
- `biosample_sampleA.txt`: List of BioSamples. Where there was no SRA run and there is only one BioSample. 3,210
- `biosample_sampleAB.tsv`: Lists of BioSamples. Where there was no SRA run and every observation has two BioSamples. 56
- `ids_run_sample_NULL.tsv`: Complete table without information for `ena_run` or `ena_sample`. 2,412
 
