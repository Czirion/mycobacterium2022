#Script to make a little matadate table from some of the Quast results 
# with only Filename, number of contigs, genome length and GC%
#Must be used from the folder that has the quast/ output folder 
# and where the metadata.tsv will be created

library(tidyverse, quietly = TRUE)
setwd(getwd())
quast_params <- read.delim("quast/report.tsv", sep = "\t",header = FALSE)
quast_params <- t(quast_params) #transpose
quast_params <- as.data.frame(quast_params) #return object to dataframe type because the transposition changed it
quast_params <- select(quast_params, V1,V14, V16, V17)
colnames(quast_params) <- c("Filename", "Contigs", "GenomeLength", "GC")
quast_params <- quast_params[-1,]
quast_params$Contigs <- as.numeric(quast_params$Contigs)
quast_params$GenomeLength <- as.numeric(quast_params$GenomeLength)
quast_params$GC <- as.numeric(quast_params$GC)

gbff_params<- read.delim("gbk_parameters.tsv", sep = '\t',header= TRUE)
metadatos <- cbind(quast_params, gbff_params)

#quitar la coma y convertir en numeros
metadatos$GenesTotal <- as.numeric(gsub(",", "", metadatos$GenesTotal))
metadatos$GenesCoding <- as.numeric(gsub(",", "", metadatos$GenesCoding))
metadatos$CDSsTotal <- as.numeric(gsub(",", "", metadatos$CDSsTotal))
metadatos$CDSsProtein <- as.numeric(gsub(",", "", metadatos$CDSsProtein))

col_order <- c("Filename","Assembly","Definition","Contigs","GenomeLength","GC","GenesTotal","CDSsTotal","GenesCoding","CDSsProtein")
metadatos <- metadatos[, col_order]
#guardar en archivo
write.table(metadatos, file='metadatos.tsv', quote=FALSE, sep='\t', row.names = FALSE)
