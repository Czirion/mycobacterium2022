library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/pubmlst/")
pubmlstMetadata<- read.table("BIGSdb_037972_2796608558_48988/pubmlst_metadata.tsv",
                         sep = "\t", 
                         header = TRUE, 
                         na.strings=c("","NA"), 
                         stringsAsFactors = TRUE, 
                         fill = TRUE,
                         quote = "")
