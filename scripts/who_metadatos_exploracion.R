#### Settings ####
library(tidyverse)
library(tools)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/")
source("scripts/who_codigos.R")
setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/metadata_fragm_tables/")

#Remove lists
rm(list= ls(pattern='list'))

#### Load all tables into dataframes ####
cargar_tablas <- function(file){
  tabla <- read.table(file,
             sep = "\t", 
             header = TRUE, 
             na.strings=c("","NA"), 
             stringsAsFactors = TRUE, 
             fill = TRUE,
             quote = "")
  return(tabla)
}
for (file in 1:15) {
   temp <- list.files(".")[file]
   assign(file_path_sans_ext(temp),cargar_tablas(temp))
   rm(file,temp)
   }

#### Rename who fragmented tables so they can be joined with the corresponding metadata ####
biosample_runA <- rename(biosample_runA, BioSample = runA)
biosample_sampleA <- rename(biosample_runA, BioSample = runA)

#### Filter all observations according to past or current methods ####

#Maintain only observations that only have NA or current in all antibiotics
who_current_or_na <- MMC2_S1 %>%
  select(isolate.name, 
         contains("classification"))%>%
  filter_at(vars(contains("classification")), all_vars(.=="WHO_current"| is.na(.)))%>%
  droplevels()

who_current_on_any <- MMC2_S1 %>%
  select(isolate.name, 
         contains("classification"))%>%
  filter_at(vars(contains("classification")), any_vars(.=="WHO_current"))%>%
  droplevels()