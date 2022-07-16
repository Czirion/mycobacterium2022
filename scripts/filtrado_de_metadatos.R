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

#### Clean host and environment####
host <- biosampleClean %>%
  select(BioSample,
         host,
         host_tissue_sampled,
         host_sex)

host$host_sex <- recode_factor(host$host_sex, "Missing" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "Not Collected" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "Unknown" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "not collected" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "not applicable" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "female" = "Female")
host$host_sex <- recode_factor(host$host_sex, "male" = "Male")

host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "Not Collected" = NA_character_)
host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "sputum" = "Sputum")
host$host_tissue_sampled[6695] <- "Sputum"

host$host <- recode_factor(host$host, "not applicable" = NA_character_)
host$host <- recode_factor(host$host, "Unknown" = NA_character_)
host$host <- recode_factor(host$host, "missing" = NA_character_)
host$host <- recode_factor(host$host, "not collected" = NA_character_)
host$host <- recode_factor(host$host, "Homo sapiens sapiens" = "Homo sapiens")
host$host <- recode_factor(host$host, "Bovine" = "Bos taurus")
host$host <- recode_factor(host$host, "bovine" = "Bos taurus")
host$host <- recode_factor(host$host, "Cattle" = "Bos taurus")
host$host <- recode_factor(host$host, "cattle" = "Bos taurus")
host$host <- recode_factor(host$host, "Suricat" = "Suricata suricatta")
host$host <- recode_factor(host$host, "chimpanzee" = "Pan troglodytes")
host$host <- recode_factor(host$host, "ethnic Koreans living in China" = "Homo sapiens")
host$host <- recode_factor(host$host, "sheep" = "Ovis aries")
host$host <- recode_factor(host$host, "wild boar" = "Sus scrofa")
host$host <- recode_factor(host$host, "elk" = "Cervus canadensis")
host$host <- recode_factor(host$host, "Dassie" = "Procavia capensis")
host$host <- recode_factor(host$host, "sea lion" = "Sea Lion")

#Information from environmentn broad scale and local scale
host$host[1947] <- "Bos taurus"
host$host[1964] <- "Homo sapiens"
host$host_tissue_sampled[5993:5997] <- "Sputum"
host$host_tissue_sampled[8] <- "Sputum"
levels(host$host) <- c(levels(host$host), "Mice")
host$host[6931] <- "Mice"
levels(host$host_tissue_sampled) <- c(levels(host$host_tissue_sampled), "Gut")
host$host_tissue_sampled[1964] <- "Gut"

names(host)[names(host) == 'host'] <- 'host_species'
host<- droplevels(host)

#### Clean disease ####
disease <- biosampleClean %>%
  select(BioSample,
         host_disease,
         host_disease_outcome,
         host_disease_stage,
         host_health_state)

disease$host_disease[3676] <- "tuberculosis" #Information from "biosampleCleaned$disease

# Convert levels without information to NAs and homogenizing names of host_disease_outcome
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Missing" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Not Collected" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Unknown" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Death of the host" = "Death")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "euthanasia" = "Euthanasia")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Chronic disease" = "Chronic")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "recovery" = "Recovered")
disease$host_disease_outcome[4168] <- "Chronic"


# Convert levels without information to NAs and homogenizing names of host_disease_stage
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "Missing" = NA_character_)
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "Not Collected" = NA_character_)
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "Unknown" = NA_character_)
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "Accute" = "Acute")
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "advanced" = "Advanced")
disease$host_disease_stage <- recode_factor(disease$host_disease_stage, "Active Pulmonary Tuberculosis" = "Active")
disease$host_disease_stage[4168] <- NA
disease$host_disease_stage[4156] <- NA

# Convert levels without information to NAs and homogenizing names of host_disease
disease$host_disease <- recode_factor(disease$host_disease, "Missing" = NA_character_)
disease$host_disease <- recode_factor(disease$host_disease, "not collected" = NA_character_)
disease$host_disease <- recode_factor(disease$host_disease, "Unknown" = NA_character_)
disease$host_disease <- recode_factor(disease$host_disease, "missing" = NA_character_)
disease$host_disease <- recode_factor(disease$host_disease, "not applicable" = NA_character_)
disease$host_disease <- recode_factor(disease$host_disease, "Pulmonary TB" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "pulmonary TB" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "Pulmonary tuberculosis" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "pulmonary tuberculosis" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "Tuberculosis of lung" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "lung tuberculosis" = "Pulmonary Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "tuberculosis" = "Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "tubercolusis" = "Tuberculosis")
disease$host_disease <- recode_factor(disease$host_disease, "Tuberculous meningitis" = "Tuberculosis Meningitis")
disease$host_disease <- recode_factor(disease$host_disease, "TB meningitis" = "Tuberculosis Meningitis")
disease$host_disease <- recode_factor(disease$host_disease, "multidrug-resistant tuberculosis" = "multidrug resistant tuberculosis")
disease$host_disease[4168] <- "Pulmonary Tuberculosis"

# Convert levels without information to NAs and homogenizing names of host_health_state
disease$host_health_state <- recode_factor(disease$host_health_state, "Missing" = NA_character_)
disease$host_health_state <- recode_factor(disease$host_health_state, "Not Collected" = NA_character_)
disease$host_health_state <- recode_factor(disease$host_health_state, "Unknown" = NA_character_)
disease$host_health_state <- recode_factor(disease$host_health_state, "unknown" = NA_character_)
disease$host_health_state <- recode_factor(disease$host_health_state, "disease" = "Disease")
disease$host_health_state <- recode_factor(disease$host_health_state, "disease: tuberculosis" = "Disease")
disease$host_health_state <- recode_factor(disease$host_health_state, "diseased" = "Disease")
disease$host_health_state <- recode_factor(disease$host_health_state, "healthy" = "Healthy")

disease <- droplevels(disease)
#### Clean geographic location ####
geography <- biosampleClean %>%
                select(BioSample,
                        geo_loc_name,
                        geographic_location_latitude,
                        geographic_location_longitude,
                        lat_lon)

#### Make one table for each column ####

make_tables <- function(tab,column){
 tabla <- tab[,c(1,column)]%>% #Make a table with only the column 1 and the column indicated by the argument "column"
    na.omit()%>% #Remove all rows with NAs
    as.data.frame() #Make it a data frame
  return(tabla)
}

dir.create("individual_metadata") #Make a directory in which individual tables for each metadata will be saved

#Use the make_tables function giving a vector with the column names to be used as table names
for (i in 2:length(dates)){
  assign(colnames(dates)[i], make_tables(dates,i)) 
  }

for (i in 2:length(disease)){
  assign(colnames(disease)[i], make_tables(disease,i)) 
}

for (i in 2:length(host)){
  assign(colnames(host)[i], make_tables(host,i)) 
}

for (i in 2:length(drugs)){
  assign(colnames(drugs)[i], make_tables(drugs,i)) 
}

for (i in 2:length(geography)){
  assign(colnames(geography)[i], make_tables(graography,i)) 
}
#Command that goes in the for loop if you want to save each table in a file
#write_tsv(assign(colnames(dates)[i], make_tables(dates,i)), paste("individual_metadata/", colnames(dates)[i], ".tsv", sep = "")) #Put each table in a file



#### Reunite cleaned columns in one table ####
useful_metadata <- full_join(collection_date, host_species)
useful_metadata <- full_join(useful_metadata, host_sex)
useful_metadata <- full_join(useful_metadata, host_tissue_sampled)
useful_metadata <- full_join(useful_metadata, host_health_state)
useful_metadata <- full_join(useful_metadata, host_disease)
useful_metadata <- full_join(useful_metadata, host_disease_stage)
useful_metadata <- full_join(useful_metadata, host_disease_outcome)
useful_metadata <- full_join(useful_metadata, drug_resistance)

drug_resistance_table <- full_join(drug_resistance, Amikacin.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Capreomicin.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Cicloserine.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Ethianamide.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Ethambutol.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Isoniazide.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Levofloxacin.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Moxifloxacin.1.0.ug.ml..resistance)
drug_resistance_table <- full_join(drug_resistance_table, Moxifloxacin.0.5.ug.ml..resistance)
drug_resistance_table <- full_join(drug_resistance_table, Ofloxacin.resistance)
drug_resistance_table <- full_join(drug_resistance_table, PAS.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Pyrazinamide.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Rifampicin.resistance)
drug_resistance_table <- full_join(drug_resistance_table, Streptomycin.resistance)

write_tsv(useful_metadata, "useful_metadata.tsv",na = "") #Put each table in a file
write_tsv(drug_resistance_table, "drug_metadata.tsv",na = "") #Put each table in a file

observaciones_completas <- na.omit(useful_metadata)

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
