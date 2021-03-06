#### Settings ####
library(tools)
source("/home/claudia/Documentos/tec/mycobacterium2022/scripts/who_codigos.R")
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

#biosample_sampleA <- rename(biosample_runA, BioSample = runA)

##### Join WHO fragmented tables with metadata tables #####
#### biosample_runA ####
biosample_runA <- rename(biosample_runA, BioSample = runA)
biosample_runA_mezcla <- full_join(biosample_runA, metadata_biosample_runA, by= "BioSample")
biosample_runA_clean <- biosample_runA_mezcla %>%
  select(isolate.name,
         BioSample,
         ena_project,
         SRA.accession,
         collection_date,
         country,
         lat_lon,
         host,
         host_health_state,
         host_disease,
         isolation_source,
         contains("classification"),
         contains("phenotype"))

# Clean the table
biosample_runA_clean$collection_date <- recode_factor(biosample_runA_clean$collection_date, "missing" = NA_character_)
biosample_runA_clean$lat_lon<- recode_factor(biosample_runA_clean$lat_lon, "missing" = NA_character_)
biosample_runA_clean$lat_lon<- recode_factor(biosample_runA_clean$lat_lon, "Not collected" = NA_character_)
biosample_runA_clean$host<- recode_factor(biosample_runA_clean$host, "missing" = NA_character_)
biosample_runA_clean$host_disease<- recode_factor(biosample_runA_clean$host_disease, "missing" = NA_character_)
biosample_runA_clean$host_disease<- recode_factor(biosample_runA_clean$host_disease, "pulmonary tuberculosis" = "Pulmonary tuberculosis")
biosample_runA_clean$host_disease<- recode_factor(biosample_runA_clean$host_disease, "Mycobacterium tuberculosis" = "Tuberculosis")
biosample_runA_clean$isolation_source<- recode_factor(biosample_runA_clean$isolation_source, "missing" = NA_character_)
biosample_runA_clean$isolation_source<- recode_factor(biosample_runA_clean$isolation_source, "not known" = NA_character_)
biosample_runA_clean$isolation_source<- recode_factor(biosample_runA_clean$isolation_source, "Not applicable" = NA_character_)
biosample_runA_clean$host_disease[c(which(biosample_runA_clean$host_health_state == "disease: tuberculosis"))] <- "Tuberculosis" #Take information from host_health_state and transfer it to host_disease

biosample_runA_clean <- biosample_runA_clean[,!(names(biosample_runA_clean) %in% "host_health_state")] #Remove host_healt_state column

biosample_runA_clean <- droplevels(biosample_runA_clean)
# Filter table according to who current methods
biosample_runA_clean_who_current_on_any<- biosample_runA_clean %>%
  filter_at(vars(contains("classification")), any_vars(.=="WHO_current"))%>%
  droplevels()


#### biosample_sampleA ####
#Está difícil mezclar las dos tablas porque la tabla de metadatos no conserva los códigos de "sample" del ENA, sino que pone los de NCBI. Entonces ya no hay ninguna columna por la cual coincidan ambas tablas

#### SRA_runA ####
SRA_runA <- rename(SRA_runA, SRA_Run = runA)
SRA_runA_mezcla<- full_join(SRA_runA, metadata_SRA_runA, by= "SRA_Run")
SRA_runA_clean <- SRA_runA_mezcla %>%
  select(isolate.name,
         SRA_Run,
         BioSample,
         ena_project,
         collection_date,
         country,
         lat_lon,
         host,
         host_health_state,
         host_disease,
         isolation_source,
         contains("classification"),
         contains("phenotype"))

SRA_runA_clean$host<- recode_factor(SRA_runA_clean$host, "\"\"\"Homo sapiens\"" = "Homo sapiens")
SRA_runA_clean$host_disease<- recode_factor(SRA_runA_clean$host_disease, "Mycobacterium tuberculosis infection" = "Tuberculosis" )
SRA_runA_clean$isolation_source<- recode_factor(SRA_runA_clean$isolation_source, "BAL" = "Bronchoalveolar lavage" )
SRA_runA_clean$isolation_source<- recode_factor(SRA_runA_clean$isolation_source, "Bronch wash" = "Bronchoalveolar lavage" )
SRA_runA_clean$isolation_source<- recode_factor(SRA_runA_clean$isolation_source, "Bronchial Alveolar Lavage" = "Bronchoalveolar lavage" )
SRA_runA_clean$isolation_source<- recode_factor(SRA_runA_clean$isolation_source, "not known" = NA_character_ )

SRA_runA_clean <- droplevels(SRA_runA_clean)

# Filter table according to who current methods
SRA_runA_clean_who_current_on_any<- SRA_runA_clean %>%
  filter_at(vars(contains("classification")), any_vars(.=="WHO_current"))%>%
  droplevels()




#### SRA_runAB ####
selected_metadatos_SRA_runAB_A <- metadata_SRA_runAB_A %>%
  select(common.name,
         geo_loc_name,
         host,
         isolate,
         isolation_source,
         sample_name)
selected_metadatos_SRA_runAB_B <- metadata_SRA_runAB_B %>%
  select(common.name,
         geo_loc_name,
         host,
         isolate,
         isolation_source,
         sample_name)
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