library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/patric/")
metadata_table <- read.table("metadata.tbl",
                               sep = "\t", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE,
                               quote = "")

filtered_by_contig <- complete_table %>%
  filter(Contigs <= 200)%>%
  droplevels()

drugs_table <- read.table("drugs.tbl",
                             sep = "\t", 
                             header = TRUE, 
                             na.strings=c("","NA"), 
                             stringsAsFactors = TRUE, 
                             fill = TRUE,
                             quote = "")