library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/reads_mtb_sra/")
sraMetadata<- read.table("SraRunInfo.csv",
                               sep = ",", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE,
                               quote = "")
biosample_list <- select(sraMetadata, BioSample)
write_tsv(biosample_list, "biosample_list.txt",na = "", col_names = FALSE) #Put the table in a file
