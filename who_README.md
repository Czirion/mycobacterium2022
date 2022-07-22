# WHO database

Here I will describe the process made to the `mmc2.xlsx` file obtained from [the publicaton](https://www.thelancet.com/journals/lanmic/article/PIIS2666-5247(21)00301-3/fulltext#supplementaryMaterial)
"The 2021 WHO catalogue of Mycobacterium tuberculosis complex mutations associated with drug resistance: a genotypic analysis".

First I made a little modification by hand on the column names of the `mmc2.xlsx` Excel file to be able to import it to R.
And then I used the script `who/obtain_run_id.R` script to do the following steps:

## Extract BioSample and SRA numbers to obtain metadata

Since not every observation (38,223 total) has an SRA run number and some have multiple SRA numbers, 
the original table was broken down into many tables in order to extract the BioSample or SRA number according to the data available.

### Table with complete information about Run, Experiment and BioSample and only one SRA Run per observation (22,155)

- `ids_todos` is the dataframe in R  
- `runs_ids_todos.tsv` has only the SRA Runs and is used to obtain the metadta with:

~~~
../scripts/biosample2table.py --in runs_ids_todos.tsv --sra --out metadata_ids_todos.tsv -e <user-email>
~~~
{: .language-bash}

### Table with BioSample information instead of SRA Runs (7,275)

`ids_runA_BioSample` is the dataframe in R with the BioSample codes in the `runA`column
