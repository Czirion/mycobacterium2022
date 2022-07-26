library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/metadata_fragm_tables/")

#### metadata_SRA_todos ####
metadata_SRA_todos <- read.table("metadata_SRA_todos.tsv",
                                 sep = "\t", 
                                 header = TRUE, 
                                 na.strings=c("","NA"), 
                                 stringsAsFactors = TRUE, 
                                 fill = TRUE,
                                 quote = "")

#### metadata_SRA_todos ####
metadata_biosample_runA <- read.table("metadata_biosample_runA.tsv",
                                 sep = "\t", 
                                 header = TRUE, 
                                 na.strings=c("","NA"), 
                                 stringsAsFactors = TRUE, 
                                 fill = TRUE,
                                 quote = "")
