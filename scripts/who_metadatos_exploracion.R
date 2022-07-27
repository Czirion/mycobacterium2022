library(tidyverse)

setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/metadata_fragm_tables/")

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

#### 