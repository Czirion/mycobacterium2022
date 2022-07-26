# WHO database

Here I will describe the process made to the `mmc2.xlsx` file obtained from [the publicaton](https://www.thelancet.com/journals/lanmic/article/PIIS2666-5247(21)00301-3/fulltext#supplementaryMaterial)
"The 2021 WHO catalogue of Mycobacterium tuberculosis complex mutations associated with drug resistance: a genotypic analysis".

First I made a little modification by hand on the column names of the `mmc2.xlsx` Excel file to be able to import it to R.
And then I used the script `who/obtain_run_id.R` script to do the following steps:

## Extract BioSample and SRA numbers to obtain metadata

Since not every observation (38,223 total) has an SRA run number and some have multiple SRA numbers, 
the original table was broken down into many tables in order to extract the BioSample or SRA number according to the data available.

## All lists

- `SRA_todos.txt` : List of SRA runs. Where there is only one run number and all other codes (project, sample and axperiment) are present. 22,155 
- `SRA_runA.txt`: List of SRA runs. Where there is only one run number and not all other codes are present. 2,880
- `SRA_runAB.tsv`: Lists of SRA runs where all observations have two run numbers. (This table has a lot of observations with repeated run numbers) 159
- `SRA_runABC.tsv`: Lists of SRA runs where all observations have three run numbers. 2
- `SRA_runABCD.tsv`: Lists of SRA runs where all observations have four run numbers. 74
- `biosample_runA.txt`: List of BioSamples. Where the BioSample code was in the `ena_run` column and there is only one BioSample. 7,275
- `biosample_sampleA.txt`: List of BioSamples. Where there was no SRA run and there is only one BioSample. 3,210
- `biosample_sampleAB.tsv`: Lists of BioSamples. Where there was no SRA run and every observation has two BioSamples. 56
- `ids_run_sample_NULL.tsv`: Complete table without information for `ena_run` or `ena_sample`. 2,412
 
### Extract metadata fragmented tables

For the files with only one column of sample or run codes:
⚡
~~~
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_todos.txt --sra --out metadata_SRA_todos.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/biosample_runA.txt --out metadata_biosample_runA.txt -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/biosample_sampleA.txt --out metadata_biosample_sampleA.txt -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runA.txt --sra --out metadata_SRA_runA.txt -e <user-email>

~~~
{: .language-bash}

For the files with two or more columns of run codes: 
(Each group of run codes in the same row should have the exact same metadata, but I want to confirm)

First, separate each column in different files:  
:zap:
~~~
grep "runA" -v  fragmented_ids_tables/SRA_runAB.tsv | cut -f1 > fragmented_ids_tables/SRA_runAB_A.txt
grep "runA" -v  fragmented_ids_tables/SRA_runAB.tsv | cut -f2 > fragmented_ids_tables/SRA_runAB_B.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABC.tsv | cut -f1 > fragmented_ids_tables/SRA_runABC_A.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABC.tsv | cut -f2 > fragmented_ids_tables/SRA_runABC_B.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABC.tsv | cut -f3 > fragmented_ids_tables/SRA_runABC_C.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABCD.tsv | cut -f1 > fragmented_ids_tables/SRA_runABCD_A.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABCD.tsv | cut -f2 > fragmented_ids_tables/SRA_runABCD_B.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABCD.tsv | cut -f3 > fragmented_ids_tables/SRA_runABCD_C.txt
grep "runA" -v  fragmented_ids_tables/SRA_runABCD.tsv | cut -f4 > fragmented_ids_tables/SRA_runABCD_D.txt
grep "ena_sampleA" -v  fragmented_ids_tables/biosample_sampleAB.tsv | cut -f1 > fragmented_ids_tables/biosample_sampleAB_A.txt
grep "ena_sampleA" -v  fragmented_ids_tables/biosample_sampleAB.tsv | cut -f2 > fragmented_ids_tables/biosample_sampleAB_B.txt


~~~
{: .language-bash}

Then extract the metadata:  
:zap:
~~~
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runAB_A.txt --sra --out metadata_SRA_runAB_A.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runAB_B.txt --sra --out metadata_SRA_runAB_B.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABC_A.txt --sra --out metadata_SRA_runABC_A.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABC_B.txt --sra --out metadata_SRA_runABC_B.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABC_C.txt --sra --out metadata_SRA_runABC_C.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABCD_A.txt --sra --out metadata_SRA_runABCD_A.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABCD_B.txt --sra --out metadata_SRA_runABCD_B.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABCD_C.txt --sra --out metadata_SRA_runABCD_C.tsv -e <user-email>
../scripts/biosample2table.py --in fragmented_ids_tables/SRA_runABCD_D.txt --sra --out metadata_SRA_runABCD_D.tsv -e <user-email>

~~~
[: .language-bash}



