library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/reads_mtb_sra/")
sraMetadata<- read.table("SraRunInfo.csv",
                               sep = ",", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE,
                               quote = "")
sraMetadata <- distinct(sraMetadata)
ids <- sraMetadata %>%
  select(Run,
         Experiment,
         SRAStudy,
         BioSample,
         SampleType)%>%
  distinct() #When distinct is added 63 observations are lost

