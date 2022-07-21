library(tidyverse)
setwd("/home/claudia/Documentos/tec/mycobacterium2022/who/")
MMC2_S1<- readxl::read_xlsx("mmc2_modificado.xlsx", sheet = "S1", col_types = "text")
cols <- colnames(MMC2_S1)
MMC2_S1[cols] <- lapply(MMC2_S1[cols], factor)

cols <- c("","b","c","d")
enaRunList <- MMC2_S1[,6] %>%
  na.omit()%>%
  as.data.frame()


cols <- c("a","b","c","d")
enaRunList <- enaRunList %>%
  filter(...6 != "ena_run")%>%
  separate(col = ...6,
           into = cols,
           sep = " ")

enaRunList[cols] <- lapply(enaRunList[cols], factor)

a <- select(enaRunList, a)%>%
  na.omit
b <- select(enaRunList, b)%>%
  na.omit
c <- select(enaRunList, c)%>%
  na.omit
d <- select(enaRunList, d)%>%
  na.omit

todos <- %>%
  distinct()
