#### Notes on pre-processing ####
# The column geographic location (country and/or sea	 region) was eliminated by hand in a spreadsheet, 
# and its information moved to column geo_loc_name
# The columns geographic location latitude and longitude had their names changed by hand in spreadsheet
#### Load table with metadata from BioSamples####
library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/ncbi_mtb_genomes/")
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

#Make only one column for collection month
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

#Join month to year to have only one column about date
dates$collection_month <- as.character(dates$collection_month)
dates$collection_date <- as.character(dates$collection_date)
dates$collection_month <- str_pad(dates$collection_month, 2, pad = "0") #Add a 0 at the begging of single digits
dates <- dates %>% 
  unite(col = "collection_date",   collection_date, collection_month, na.rm=TRUE, sep = "-")
dates$collection_date[dates$collection_date == ""] <- NA #Return blanks to NAs
dates$collection_date <- as.factor(dates$collection_date)

#Give format to some dates
dates$collection_date <- recode_factor(dates$collection_date, "February 26, 207" = "2007-02-26")
dates$collection_date <- recode_factor(dates$collection_date, "22/25/2010" = "2010")
dates$collection_date <- recode_factor(dates$collection_date, "2009/05/11" = "2009-05-11")
dates$collection_date <- recode_factor(dates$collection_date, "2007/04/02" = "2007-04-02")

#### Clean drug resistance ####
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

#Add Information from subsrc_note
drugs$note[4156] <- "multidrug-resistant" 

# Homogenize levels
drugs$note <- recode_factor(drugs$note, "extensively drug resistant" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "multidrug-resistant strain" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "multi-drug resistant" = "multidrug-resistant")
drugs$note <- recode_factor(drugs$note, "resistant to isoniazid, rifampicin, streptomycin and ethambutol" = "multidrug-resistant") # This is for sample SAMN02603011 [3916]

# Convert column note to column about drug_resistance
drugs$note <- as.character(drugs$note)
drugs$note[drugs$note != "multidrug-resistant"] <- NA #Erase all information that is not about drug resistance 
drugs$note <- as.factor(drugs$note)
names(drugs)[names(drugs) == 'note'] <- 'drug_resistance'

#Put in the corresponding column the information from Drug.Susceptibility.Testing.Profiles, and delete this column
#And add information from orgmod_note column
drugs$Rifampicin.resistance[c(6741,6742,6743,6744,6745,3916, 4184)] <- "Yes"
drugs$Isoniazide.resistance[c(6741,6743,6744,6745,3916, 3346:3348, 4184)] <- "Yes"
drugs["Ethambutol.resistance"] <- NA
drugs$Ethambutol.resistance[c(6741,6745,3916)] <- "Yes"
drugs$Ethambutol.resistance <- as.factor(drugs$Ethambutol.resistance)
drugs["Streptomycin.resistance"] <- NA
drugs$Streptomycin.resistance[c(6741,6745,3916, 4184)] <- "Yes"
drugs$Streptomycin.resistance <- as.factor(drugs$Streptomycin.resistance)
drugs["Pyrazinamide.resistance"] <- NA
drugs$Pyrazinamide.resistance[c(6741,6745, 4184)] <- "Yes"
drugs$Pyrazinamide.resistance <- as.factor(drugs$Pyrazinamide.resistance)
levels(drugs$drug_resistance) <- c(levels(drugs$drug_resistance), "sensitive")
drugs$drug_resistance[c(6746,6747,6748,6749,6750,4057, 3337)] <- "sensitive"
drugs$drug_resistance[c(5629, 3273, 3319, 3320, 3272)] <- "multidrug-resistant"
drugs <- drugs[,!(names(drugs) %in% "Drug.Susceptibility.Testing.Profiles")]

#### Clean host and environment####
host <- biosampleClean %>%
  select(BioSample,
         host,
         host_tissue_sampled,
         isolation_source,
         orgmod_note,
         host_sex)

host$host_sex <- recode_factor(host$host_sex, "Missing" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "Not Collected" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "Unknown" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "not collected" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "not applicable" = NA_character_)
host$host_sex <- recode_factor(host$host_sex, "female" = "Female")
host$host_sex <- recode_factor(host$host_sex, "male" = "Male")

# Information from isolation_source
host$host_tissue_sampled <- as.character(host$host_tissue_sampled)
host$host_tissue_sampled[c(6695, 3968,6720,4185, 4186, 4156, 3687, 3688, 3979, 4154, 4204, 4205, 4184, 3916, 4111, 5422:5425, 6712, 6713,which(host$isolation_source == "sputum"),which(host$isolation_source == "Human sputum"))] <- "Sputum" #Information from host_description
host$host_tissue_sampled[6513] <- "Vertebral"
host$host_tissue_sampled[6530] <- "Urine"
host$host_tissue_sampled[4174] <- "Tracheal secretion"
host$host_tissue_sampled[4000] <- "Testis"
host$host_tissue_sampled[5985] <- "Superficial abscess"
host$host_tissue_sampled[c(6932:6935)] <- "Skin"
host$host_tissue_sampled[c(3047, 3048, 3041, 3051, 3053, which(host$isolation_source == "excreted bodily substance"))] <- "Secretion"
host$host_tissue_sampled[5450] <- "Retropharyngeal, hepatic and mesenteric lymph Nnodes"
host$host_tissue_sampled[5449] <- "Retropharyngeal lymph node"
host$host_tissue_sampled[2987] <- "Retroperitoneal abscess"
host$host_tissue_sampled[3046] <- "Colon"
host$host_tissue_sampled[c(3035, 6751, 6765)] <- "Pus"
host$host_tissue_sampled[c(6531:6541, which(host$isolation_source == "lung"))] <- "Lung"
host$host_tissue_sampled[5619] <- "Pre-scapular limph node"
host$host_tissue_sampled[c(3980, 6761, 6762, 3, 3049)] <- "Pleural fluid"
host$host_tissue_sampled[c(3037, 3038)] <- "Pericard"
host$host_tissue_sampled[4115] <- "Pectoral limph nodes"
host$host_tissue_sampled[3989] <- "Pancreas"
host$host_tissue_sampled[c(5623, 5625, 1963, 1959)] <- "Mesentery lymph node"
host$host_tissue_sampled[5545] <- "Mediastinal lymph node"
host$host_tissue_sampled[4215] <- "Mandibular lymph node"
host$host_tissue_sampled[5447] <- "Lymph nodes, lungs, pleura"
host$host_tissue_sampled[c(6830, 6831)] <- "Lymph node necropsy"
host$host_tissue_sampled[5407] <- "Lymph node and lung"
host$host_tissue_sampled[c(4004, 6682, which(host$isolation_source == "Lymph nodes"))] <- "Lymph nodes"
host$host_tissue_sampled[c(2974, 2988, 2991, 2994)] <- "Lymph gland"
host$host_tissue_sampled[5433] <- "Lungs, pleura"
host$host_tissue_sampled[c(4100, 4162)] <- "Laryngopharyngeal lymph node"
host$host_tissue_sampled[4013] <- "Kidney"
host$host_tissue_sampled[1964] <- "Gut"
host$host_tissue_sampled[c(1965, 1966, which(host$isolation_source == "bronchial fluid"))] <- "Bronchial fluid"
host$host_tissue_sampled[c(5620, 5622, 5624)] <- "Head lymph node"
host$host_tissue_sampled[c(2973, 3080, 3091, 3108)] <- "Gland"
host$host_tissue_sampled[4181] <- "Gastric lavage"
host$host_tissue_sampled[c(3009, 3032)] <- "Feces"
host$host_tissue_sampled[6811] <- "Fermented dairy"
host$host_tissue_sampled[6834] <- "Eye"
host$host_tissue_sampled[1949] <- "Crachat"
host$host_tissue_sampled[1958] <- "Cervical lymph node"
host$host_tissue_sampled[c(3344, 5451, which(host$isolation_source == "CSF"), which(host$isolation_source == "cerebrospinal fluid"))] <- "Cerebrospinal fluid"
host$host_tissue_sampled[3078] <- "Cerebrospinal"
host$host_tissue_sampled[4016] <- "Bronchus"
host$host_tissue_sampled[c(6510, 6514, 6663, 6679, 6684, which(host$isolation_source == "BAL"))] <- "Bronchoalveolar lavage"
host$host_tissue_sampled[1] <- "Bronchial wash"
host$host_tissue_sampled[c(3056,which(host$isolation_source == "bronchial"))] <- "Bronchial"
host$host_tissue_sampled[c(4218, 5465)] <- "Brain"
host$host_tissue_sampled[c(2264, 2265)] <- "Milk"
host$host_tissue_sampled[c(which(host$isolation_source == "abscess"))] <- "Abscess"
  
host$host_tissue_sampled <- as.factor(host$host_tissue_sampled)

host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "Not Collected" = NA_character_)
host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "sputum" = "Sputum")
host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "retropharyngeal lymph node" = "Retropharyngeal lymph node")
host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "mediastinal lymph node" = "Mediastinal lymph node")
host$host_tissue_sampled <- recode_factor(host$host_tissue_sampled, "granulomatous lesion in lymph node" = "Granulomatous lesion in lymph node")


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

#Information from environment broad scale and local scale
host$host[1947] <- "Bos taurus"
host$host[c(1964,1965, 1966)] <- "Homo sapiens" #And information from isolation source
host$host_tissue_sampled[c(5993:5997)] <- "Sputum"
host$host_tissue_sampled[8] <- "Sputum"
levels(host$host) <- c(levels(host$host), "Mice")
host$host[6931] <- "Mice"
levels(host$host_tissue_sampled) <- c(levels(host$host_tissue_sampled), "Gut")
host$host_tissue_sampled[1964] <- "Gut"

#Change column host to be named host_species
names(host)[names(host) == 'host'] <- 'host_species'
host<- droplevels(host) #Remove all levels that are not used
host <- host[,!(names(host) %in% c("isolation_source", "orgmod_note"))]

#### Clean disease ####
disease <- biosampleClean %>%
  select(BioSample,
         host_disease,
         host_disease_outcome,
         host_disease_stage,
         host_health_state)

disease$host_disease[3676] <- "tuberculosis" #Information from biosampleCleaned$disease

# Convert levels without information to NAs and homogenizing names of host_disease_outcome
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Missing" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Not Collected" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Unknown" = NA_character_)
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Death of the host" = "Death")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "euthanasia" = "Euthanasia")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "Chronic disease" = "Chronic")
disease$host_disease_outcome <- recode_factor(disease$host_disease_outcome, "recovery" = "Recovered")
disease$host_disease_outcome[4168] <- "Chronic" #Information from host_disease_stage


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
disease$host_disease[4168] <- "Pulmonary Tuberculosis" #Information from host_disease_stage

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

#Make a column for hospitals and remove this information from geo_loc_name
hospitals <- c( "Church of Scotland", 
   "Goodwins Clinic", 
   "M3 TB Hospital",
   "Osindisweni Hospital - Occ Health, staff clinic",
   "Siloah Clinic",
   "St Margaret's Hospital",
   "Stanger Hospital",
   "Catherine Booth",
   "Christ The King Hospital",
   "Chwezi Clinic",
   "Dundee Hospital",
   "Ethembeni Clinic",
   "hospital",
   "St Margaret's TB Hospital")
geography$geo_loc_name <- as.character(geography$geo_loc_name)
geography <- geography %>%
                       mutate(hospital = ifelse(geo_loc_name %in% hospitals, geo_loc_name, NA),
                              geo_loc_name = ifelse(geo_loc_name %in% hospitals, NA, geo_loc_name))
geography$hospital <- as.factor(geography$hospital)
geography$geo_loc_name <- as.factor(geography$geo_loc_name)

#Separate geo_loc_name in country and region
geography <- geography %>%
                separate(col= geo_loc_name, 
                         into= c("country", "region"), 
                        sep = ": ")%>%
                separate(col= country, 
                         into= c("country", "region"), 
                         sep = ":" )
geography$country <- as.factor(geography$country)
geography$region <- as.factor(geography$region)

geography$country <- recode_factor(geography$country, "missing" = NA_character_)
geography$country <- recode_factor(geography$country, "not applicable" = NA_character_)
geography$country <- recode_factor(geography$country, "N/A" = NA_character_)
geography$country <- recode_factor(geography$country, "Not applicable" = NA_character_)
geography$country <- recode_factor(geography$country, "not collected" = NA_character_)
geography$country <- recode_factor(geography$country, "Unknown" = NA_character_)

geography$lat_lon <- recode_factor(geography$lat_lon, "missing" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "not applicable" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "N/A" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "n/a" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "Not Applicable" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "Not collected" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "Not Collected" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "Not applicable" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "not collected" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "Unknown" = NA_character_)
geography$lat_lon <- recode_factor(geography$lat_lon, "-" = NA_character_)

geography <- geography %>%
  separate(col = lat_lon, into=c("latitude","NS_lat","longitude","WE_lon"),sep= " ")

geography$latitude <- as.factor(geography$latitude)
geography$NS_lat <- as.factor(geography$NS_lat)
geography$longitude <- as.factor(geography$longitude)
geography$WE_lon <- as.factor(geography$WE_lon)

geography <- droplevels(geography)

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
  write_tsv(assign(colnames(dates)[i], make_tables(dates,i)), paste("individual_metadata/", colnames(dates)[i], ".tsv", sep = "")) #Put each table in a file
}

for (i in 2:length(disease)){
  assign(colnames(disease)[i], make_tables(disease,i)) 
  write_tsv(assign(colnames(disease)[i], make_tables(disease,i)), paste("individual_metadata/", colnames(disease)[i], ".tsv", sep = "")) #Put each table in a file
  
}

for (i in 2:length(host)){
  assign(colnames(host)[i], make_tables(host,i))
  write_tsv(assign(colnames(host)[i], make_tables(host,i)), paste("individual_metadata/", colnames(host)[i], ".tsv", sep = "")) #Put each table in a file
  
}

for (i in 2:length(drugs)){
  assign(colnames(drugs)[i], make_tables(drugs,i)) 
  write_tsv(assign(colnames(drugs)[i], make_tables(drugs,i)), paste("individual_metadata/", colnames(drugs)[i], ".tsv", sep = "")) #Put each table in a file
  
}

for (i in 2:length(geography)){
  assign(colnames(geography)[i], make_tables(geography,i))
  write_tsv(assign(colnames(geography)[i], make_tables(geography,i)), paste("individual_metadata/", colnames(geography)[i], ".tsv", sep = "")) #Put each table in a file
  
}
#Command that goes in the for loop if you want to save each table in a file
#write_tsv(assign(colnames(dates)[i], make_tables(dates,i)), paste("individual_metadata/", colnames(dates)[i], ".tsv", sep = "")) #Put each table in a file



#### Reunite cleaned columns in one table ####
useful_metadata <- full_join(collection_date, country)
useful_metadata <- full_join(useful_metadata, host_species)
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

observaciones_completas <- na.omit(useful_metadata)

write_tsv(useful_metadata, "useful_metadata.tsv",na = "") #Put each table in a file
write_tsv(drug_resistance_table, "drug_metadata.tsv",na = "") #Put each table in a file
write_tsv(observaciones_completas, "observaciones_completas.tsv",na = "") #Put each table in a file

#### Load tables with assembly metadata ####
assemblyMetadata<- read.table("assembly_metadata.tsv",
                               sep = "\t", 
                               header = TRUE, 
                               na.strings=c("","NA"), 
                               stringsAsFactors = TRUE, 
                               fill = TRUE, 
                               quote = "")

assemblyMetadataSelect <- assemblyMetadata %>%
                                select(Assembly = assembly_accession,
                                       BioSample= biosample,
                                       bioproject,
                                       organism_name,
                                       infraspecific_name)%>%
                                distinct() #Rows are repeated because there is a row for the fasta and one for the gbff, so here the repetition is deleated.

#The headers were modified by hand to the current names for easiness of importation
quastReport <-read.table("quast_transposed_report_modif.tsv",
                         sep = "\t", 
                         header = TRUE, 
                         na.strings=c("","NA"), 
                         stringsAsFactors = TRUE, 
                         fill = TRUE, 
                         quote = "")

quastReportSelect <- quastReport %>%
  separate(col = Assembly,
           into = c("GCF", "assembly", "code", "genomic"),
           sep = "_") %>%
  unite(col = "Assembly",   GCF, assembly, na.rm=TRUE, sep = "_") %>%
  select(Assembly,
         contigs,
         Largest_contig,
         Total_length,
         GC)



#### Join tables with assembly metadata ####
bio_assembly_metadata <- full_join(assemblyMetadataSelect, quastReportSelect)
bio_assembly_metadata <- full_join(bio_assembly_metadata, useful_metadata)
write_tsv(bio_assembly_metadata, "bio_assembly_metadata.tsv",na = "") #Put the table in a file
