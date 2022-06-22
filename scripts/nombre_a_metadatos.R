library(tidyverse)
setwd(getwd())
metadatos<- read.delim("metadatos.tsv", sep = "\t",header = TRUE)
nombres<- read.delim("nombre.txt", sep= " ", header = FALSE)
