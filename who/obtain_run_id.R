library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/")
#The mmc2.xlsx table downloaded from the WHO was manualy modified to include antibiotic name in columns about it
MMC2_S1<- readxl::read_xlsx("mmc2_modificado.xlsx", sheet = "S1", col_types = "text")
cols <- colnames(MMC2_S1)
MMC2_S1[cols] <- lapply(MMC2_S1[cols], factor)

#### Filter codes ####
# Table with observations that have all sample, experiment and run codes.
# In this set there is no case with multiple runs per observation
ids_todos <- MMC2_S1 %>%
  filter(!is.na(ena_run) &
         !is.na(ena_experiment) &
         !is.na(ena_sample))

runs_ids_todos <- select(ids_todos, ena_run)
write_tsv(runs_ids_todos, "runs_ids_todos.tsv", col_names = FALSE)
  
# Complement of previous table. 
# Here at least one or ena_run, ena_sample, ena_experiment has an NA
# And ena_run column was devided into four, because some samples has ut to four runs
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
ids_runA <- ids_complemento %>%
  filter(!is.na(runA) &
           is.na(runB) &
           is.na(runC) &
           is.na(runD)) %>%
  select(-c(runB, runC, runD))%>%
  droplevels()

#Table with BioSample codes instead or Run codes
ids_runA_BioSample <- ids_runA %>%
  filter(grepl('SAM', runA))%>%
  droplevels()

biosam_ids_runA <- select(ids_runA_BioSample, runA)
write_tsv(biosam_ids_runA, "biosam_ids_runA.txt", col_names = FALSE)

ids_runA_SRA <- ids_runA %>%
  filter(grepl('SRR|ERR', runA))%>%
  droplevels()

rm(ids_runA)

# This is a list of the SRA runs that have two observations.
# Apparently one is a measurement with past_WHO category and the other one with current_WHO
conts <- as.data.frame(count(ids_runA_SRA, runA)) %>%
  filter(n == 2)

ejemplo_doble_run <- ids_runA_SRA %>%
  filter(runA %in% conts$runA)%>%
  arrange(runA)
write_tsv(ejemplo_doble_run, "ejemplo_doble_run.tsv")

# Table with observations with two runs (runA and runB)
ids_runAB <- ids_complemento %>%
  filter(!is.na(runA) &
         !is.na(runB) &
         is.na(runC) &
          is.na(runD))%>%
  select(-c(runC, runD))%>%
  droplevels()

# Table with observations with three runs (runA,runB, runC)
ids_runABC <- ids_complemento %>%
  filter(!is.na(runA) &
           !is.na(runB) &
           !is.na(runC) &
           is.na(runD))%>%
  select(-runD)%>%
  droplevels()

write.table(ids_runABC, "ejemplo_multiples_runs.tsv", sep = "\t", row.names = FALSE)

# Table with observations with four runs (runA,runB, runC, runD)
ids_runABCD <- ids_complemento %>%
  filter(!is.na(runA) &
           !is.na(runB) &
           !is.na(runC) &
           !is.na(runD))%>%
  droplevels()

# Table with observations that do not have a run code
ids_runNULL <- ids_complemento %>%
  filter(is.na(runA) &
         is.na(runB) &
         is.na(runC) &
         is.na(runD))%>%
  select(-c(runA, runB, runC, runD))%>%
  droplevels()

rm(ids_complemento)

#### Filter all observations according to pasto or current methods ####

category_who <- select(MMC2_S1,
               contains("classification"))
