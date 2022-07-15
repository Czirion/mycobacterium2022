#### Notes on pre-processing ####
# The column geographic location (country and/or sea	 region) was eliminated by hand in spreadsheet, 
# and its information moved to column geo_loc_name
# The columns geographic location latitude and longitude had their names changed by hand in spreadsheet
#### Load table with metadata from BioSamples####
library(tidyverse)
setwd("/home/claudia/Documentos/tec-Cuahutemoc/mycobacterium2022/ncbi_mtb_genomes/")
biosampleMetadata<- read.table("metadata_biosamples_modif.tsv",
                              sep = "\t", 
                              header = TRUE, 
                              na.strings=c("","NA"), 
                              stringsAsFactors = TRUE, 
                              fill = TRUE,
                              quote = "")
#### Remain with relevant columns only ####
biosampleClean <- biosampleMetadata %>%
  select(BioSample,
         Amikacin.resistance,
         Capreomicin.resistance,
         Cicloserine.resistance,
         Drug.Susceptibility.Testing.Profiles,
         Ethianamide.resistance,
         Isoniazide.resistance,
         Levofloxacin.resistance,
         Moxifloxacin.0.5.ug.ml..resistance,
         Moxifloxacin.1.0.ug.ml..resistance,
         Ofloxacin.resistance,
         PAS.resistance,
         Rifampicin.resistance,
         SRA.accession,
         collection.month,
         collection_month,
         collection_date,
         description,
         disease,
         env_broad_scale,
         env_local_scale,
         env_medium,
         genotype,
         geo_loc_name,
         geographic_location_latitude,
         geographic_location_longitude,
         growth_med,
         health_state,
         host,
         host.associated.environmental.package,
         host_age,
         host_description,
         host_disease,
         host_disease_outcome,
         host_disease_stage,
         host_health_state,
         host_sex,
         host_taxid,
         host_tissue_sampled,
         isol_growth_condt,
         isolate,
         isolate_name_alias,
         isolation_source,
         label,
         lat_lon,
         note,
         orgmod_note,
         passage_history,
         pathotype,
         pmid,
         region,
         sample_type,
         serotype,
         serovar,
         subgroup,
         subspecf_gen_lin,
         subsrc_note,
         subtype,
         supplier_name,
         type.material)

write_tsv(biosampleClean, "metadata_biosample_relevant.tsv")

#### Clean dates ####
dates <- biosampleClean %>%
                select(BioSample,
                       collection.month,
                       collection_month,
                       collection_date)

dates$collection.month[is.na(dates$collection.month)] <- 0 #Convert NAs in 0s
dates$collection_month[is.na(dates$collection_month)] <- 0 #Convert NAs in 0s
dates <- dates %>%
  summarize(BioSample = BioSample,
            collection_month = collection_month+collection.month, # Make only one column for collection month making the sum between both month columns
            collection_date = collection_date)
dates$collection_month[dates$collection_month == 0] <- NA #Return 0s to NAs

# Convert levels without date to NAs
dates$collection_date <- recode_factor(dates$collection_date, "Missing" = NA_character_)
dates$collection_date <- recode_factor(dates$collection_date, "missing" = NA_character_)
dates$collection_date <- recode_factor(dates$collection_date, "not applicable" = NA_character_)
dates$collection_date <- recode_factor(dates$collection_date, "not collected" = NA_character_)
dates$collection_date <- recode_factor(dates$collection_date, "unknown" = NA_character_)
dates$collection_date <- recode_factor(dates$collection_date, "Unknown" = NA_character_)

dates$collection_month <- as.character(dates$collection_month)
dates$collection_date <- as.character(dates$collection_date)
dates$collection_month <- str_pad(dates$collection_month, 2, pad = "0") #Add a 0 at the beggining of single digits

dates <- dates %>% 
  unite(col = "collection_date",   collection_date, collection_month, na.rm=TRUE, sep = "-")

dates$collection_date[dates$collection_date == ""] <- NA #Return blanks to NAs
dates$collection_date <- as.factor(dates$collection_date)
#Give format to some dates
dates$collection_date <- recode_factor(dates$collection_date, "February 26, 207" = "2007-02-26")
dates$collection_date <- recode_factor(dates$collection_date, "22/25/2010" = "2010")
dates$collection_date <- recode_factor(dates$collection_date, "2009/05/11" = "2009-05-11")
dates$collection_date <- recode_factor(dates$collection_date, "2007/04/02" = "2007-04-02")

#### Clean Drug resistance ####
drugs <- biosampleClean %>%
  select(BioSample,
         note,
         Amikacin.resistance,
         Capreomicin.resistance,
         Cicloserine.resistance,
         Ethianamide.resistance,
         Isoniazide.resistance,
         Levofloxacin.resistance,
         Moxifloxacin.0.5.ug.ml..resistance,
         Moxifloxacin.1.0.ug.ml..resistance,
         Ofloxacin.resistance,
         PAS.resistance,
         Rifampicin.resistance,
         Drug.Susceptibility.Testing.Profiles)

drugs$note[4156] <- "multidrug-resistant"
drugs$note <- recode_factor(drugs$note, "extensively drug resistant" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "multidrug-resistant strain" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "multi-drug resistant" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "resistant to isoniazid, rifampicin, streptomycin and ethambutol" = "multidrug-resistant") # This is for sample SAMN02603011 [3916]

drugs$note <- as.character(drugs$note)
drugs$note[drugs$note != "multidrug-resistant"] <- NA
drugs$note <- as.factor(drugs$note)
names(drugs)[names(drugs) == 'note'] <- 'drug_resistance'

#Put in the corresponding column the information from Drug.Susceptibility.Testing.Profiles, and delete this column
drugs$Rifampicin.resistance[c(6741,6742,6743,6744,6745,3916)] <- "Yes"
drugs$Isoniazide.resistance[c(6741,6743,6744,6745,3916)] <- "Yes"
drugs["Ethambutol.resistance"] <- NA
drugs$Ethambutol.resistance[c(6741,6745,3916)] <- "Yes"
drugs$Ethambutol.resistance <- as.factor(drugs$Ethambutol.resistance)
drugs["Streptomycin.resistance"] <- NA
drugs$Streptomycin.resistance[c(6741,6745,3916)] <- "Yes"
drugs$Streptomycin.resistance <- as.factor(drugs$Streptomycin.resistance)
drugs["Pyrazinamide.resistance"] <- NA
drugs$Pyrazinamide.resistance[c(6741,6745)] <- "Yes"
drugs$Pyrazinamide.resistance <- as.factor(drugs$Pyrazinamide.resistance)
levels(drugs$drug_resistance) <- c(levels(drugs$drug_resistance), "sensitive")
drugs$drug_resistance[c(6746,6747,6748,6749,6750)] <- "sensitive"
drugs <- drugs[,!(names(drugs) %in% "Drug.Susceptibility.Testing.Profiles")]

#### Clean Environment ####
environment<- biosampleClean %>%
  select(BioSample,
         disease,
         env_broad_scale,
         env_local_scale,
         env_medium,
         growth_med,
         health_state,
         host,
         host.associated.environmental.package,
         host_age,
         host_description,
         host_disease,
         host_disease_outcome,
         host_disease_stage,
         host_health_state,
         host_sex,
         host_taxid,
         host_tissue_sampled)
         
#### Make one table for each column ####

make_tables <- function(column){
 tabla <- biosampleClean[,c(1,column)]%>% #Make a table with only the column 1 and the column indicated by the argument "column"
    na.omit()%>% #Remove all rows with NAs
    as.data.frame() #Make it a data frame
  return(tabla)
}
dir.create("individual_metadata") #Make a directory in which individual tables for each metadata will be saved

for (i in 2:length(biosampleClean)){
  assign(colnames(biosampleClean)[i], make_tables(i)) #Use the make_tables function giving a vector with the column names to be used as table names
  write_tsv(assign(colnames(biosampleClean)[i], make_tables(i)), paste("individual_metadata/", colnames(biosampleClean)[i], ".tsv", sep = "")) #Put each table in a file
  }



#### Load table with assembly metadata ####
assemblyMetadata<- read.table("assembly_metadata.tsv",
                               sep = "\t", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE, 
                               quote = "")
organismBiosample <- select(assemblyMetadata, 
                            biosample, 
                            organism_name, 
                            infraspecific_name)
