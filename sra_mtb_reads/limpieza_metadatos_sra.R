library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/sra_mtb_reads//")
sraMetadata<- read.table("SraRunInfo.csv",
                               sep = ",", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE,
                               quote = "")
