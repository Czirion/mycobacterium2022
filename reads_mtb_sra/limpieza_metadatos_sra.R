library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/reads_mtb_sra/")
sraMetadata<- read.table("SraRunInfo.csv",
                               sep = ",", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE,
                               quote = "")

