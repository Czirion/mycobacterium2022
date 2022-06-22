#Script to make a little matadate table from some of the Quast results 
# with only Filename, number of contigs, genome length and GC%
#Must be used from the folder that has the quast/ output folder 
# and where the metadata.tsv will be created

library(tidyverse, quietly = TRUE)
setwd(getwd())
parametros <- read.delim("quast/report.tsv", sep = "\t",header = FALSE)
parametros <- t(parametros) #transpose
parametros <- as.data.frame(parametros) #return object to dataframe type because the transposition changed it
parametros <- select(parametros, V1,V14, V16, V17)
colnames(parametros) <- c("Filename", "Contigs", "GenomeLength", "GC")
parametros <- parametros[-1,]
parametros$Contigs <- as.numeric(parametros$Contigs)
parametros$GenomeLength <- as.numeric(parametros$GenomeLength)
parametros$GC <- as.numeric(parametros$GC)
write.table(parametros, file='metadatos.tsv', quote=FALSE, sep='\t', row.names = FALSE)
