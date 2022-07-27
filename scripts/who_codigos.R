library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/")
#The mmc2.xlsx table downloaded from the WHO was manualy modified to include antibiotic name in columns about it
MMC2_S1<- readxl::read_xlsx("mmc2_modificado.xlsx", sheet = "S1", col_types = "text", .name_repair = "universal")
MMC2_S1 <- as.data.frame(MMC2_S1)
cols <- colnames(MMC2_S1)
MMC2_S1[cols] <- lapply(MMC2_S1[cols], factor)

dir.create("fragmented_ids_tables") 
#### Filter by available codes ####
# Table with observations that have all sample, experiment and run codes.
# In this set there is no case with multiple runs per observation
SRA_todos <- MMC2_S1 %>%
  filter(!is.na(ena_run) &
         !is.na(ena_experiment) &
         !is.na(ena_sample))

SRA_todos_list <- select(SRA_todos, ena_run)
write_tsv(SRA_todos_list, "fragmented_ids_tables/SRA_todos.txt", col_names = FALSE)
  
# Complement of previous table. 
# Here at least one or ena_run, ena_sample, ena_experiment has an NA
# And ena_run column was divided into four, because some samples have up to four runs
cols <- c("runA","runB","runC","runD")
ids_complemento <- MMC2_S1 %>%
  filter(is.na(ena_run) |
         is.na(ena_experiment) |
         is.na(ena_sample)) %>%
  separate(col = ena_run,
           into = cols,
           sep = " ")
ids_complemento[cols] <- lapply(ids_complemento[cols], factor)
rm(cols)

# Table with observations with only one run (runA)
runA_mix <- ids_complemento %>%
  filter(!is.na(runA) &
           is.na(runB) &
           is.na(runC) &
           is.na(runD)) %>%
  select(-c(runB, runC, runD))%>%
  droplevels()

#Table with BioSample codes instead or Run codes
biosample_runA <- runA_mix %>%
  filter(grepl('SAM', runA))%>%
  droplevels()

biosample_runA_list <- select(biosample_runA, runA)
write_tsv(biosample_runA_list, "fragmented_ids_tables/biosample_runA.txt", col_names = FALSE)

#Table with only one SRA Run
# It has four cases where the same SRA Run is in two observations
SRA_runA <- runA_mix %>%
  filter(grepl('SRR|ERR', runA))%>%
  droplevels()
SRA_runA_list <- select(SRA_runA, runA)
write_tsv(SRA_runA_list, "fragmented_ids_tables/SRA_runA.txt", col_names = FALSE)

# This is a list of the SRA runs that have two observations.
# Apparently one is a measurement with past_WHO category and the other one with current_WHO
# conts <- as.data.frame(count(ids_runA_SRA, runA)) %>%
#  filter(n == 2)

rm(runA_mix)

# Table with observations with two runs (runA and runB)
SRA_runAB <- ids_complemento %>%
  filter(!is.na(runA) &
         !is.na(runB) &
         is.na(runC) &
          is.na(runD))%>%
  select(-c(runC, runD))%>%
  droplevels()

SRA_runAB_lists <- select(SRA_runAB, runA, runB)
write_tsv(SRA_runAB_lists, "fragmented_ids_tables/SRA_runAB.tsv")


# Table with observations with three runs (runA,runB, runC)
SRA_runABC <- ids_complemento %>%
  filter(!is.na(runA) &
           !is.na(runB) &
           !is.na(runC) &
           is.na(runD))%>%
  select(-runD)%>%
  droplevels()
SRA_runABC_lists <- select(SRA_runABC, runA, runB, runC)
write_tsv(SRA_runABC_lists, "fragmented_ids_tables/SRA_runABC.tsv")

# Table with observations with four runs (runA,runB, runC, runD)
SRA_runABCD <- ids_complemento %>%
  filter(!is.na(runA) &
           !is.na(runB) &
           !is.na(runC) &
           !is.na(runD))%>%
  droplevels()

SRA_runABCD_lists <- select(SRA_runABCD, runA, runB, runC, runD)
write_tsv(SRA_runABCD_lists, "fragmented_ids_tables/SRA_runABCD.tsv")

# Table with observations that do not have a run code
ids_runNULL <- ids_complemento %>%
  filter(is.na(runA) &
         is.na(runB) &
         is.na(runC) &
         is.na(runD))%>%
  select(-c(runA, runB, runC, runD))%>%
  droplevels()

cols <- c("ena_sampleA", "ena_sampleB")
ids_noRun_Biosamples <- ids_runNULL %>%
  filter(!is.na(ena_sample))%>%
  separate(col = ena_sample,
           into = cols,
           sep = " ")%>%
  droplevels()
ids_noRun_Biosamples[cols] <- lapply(ids_noRun_Biosamples[cols], factor)

biosample_sampleA <- ids_noRun_Biosamples %>%
  filter(!is.na(ena_sampleA) &
           is.na(ena_sampleB)) %>%
  select(-c(ena_sampleB))%>%
  droplevels()

biosample_sampleA_list <- select(biosample_sampleA, ena_sampleA)
write_tsv(biosample_sampleA_list, "fragmented_ids_tables/biosample_sampleA.txt", col_names = FALSE)

biosample_sampleAB <- ids_noRun_Biosamples %>%
  filter(!is.na(ena_sampleA) &
         !is.na(ena_sampleB)) %>%
  droplevels()

biosample_sampleAB_lists <- select(biosample_sampleAB, ena_sampleA, ena_sampleB)
write_tsv(biosample_sampleAB_lists, "fragmented_ids_tables/biosample_sampleAB.tsv")

ids_run_sample_NULL <- ids_runNULL %>%
  filter(is.na(ena_sample))%>%
  droplevels()

write_tsv(ids_run_sample_NULL, "fragmented_ids_tables/ids_run_sample_NULL.tsv")

rm(ids_complemento, ids_noRun_Biosamples, ids_runNULL)




