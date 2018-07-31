# Created by: Fadel Megahed (Email: fmegahed@miamioh.edu)
# To perform a quick bibliometric analysis on Web of Sci
# Data obtained using:  
# TOPIC: ("hazmat transportation" OR "real-time crash prediction" OR 
#         ("vehicle routing" AND safety))
# without limiting the document type, years, language

# The search was performed using WoS Core Collection
# Resulted in the download of a plain txt file
# containing the full record with cited references for 
# 992 results (7/30/2018 - 11:08 am ET)

# Package Installation and Setting the Working Dir
#--------------------------------------------------
#install.packages("pacman") # install if needed
library(pacman)
p_load(bibliometrix,ggplot2,data.table,rvest,dplyr,
       rstudioapi) # Assuming R Studio is the IDE
# automatically getting the file's wd using rstudio api
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # only tested in RStudio environment 

# Cleaning screen and global environment
cat("\014") 
rm(list=ls())
graphics.off()

# Reading the WoS Data File
df.trans.safety <- readFiles("savedrecs.txt")
M <-convert2df(df.trans.safety)

#------------------------------------------------------



#----------------------------------------------------------
# Bibliometric Analysis (Per the Bibliometrix Guide)
# See https://cran.r-project.org/web/packages/bibliometrix/vignettes/bibliometrix-vignette.html
results <- biblioAnalysis(M, sep = ";")
# Options modified for this analysis purposes
options(width=100)
S <- capture.output(summary(object = results, k = 10, pause = FALSE))
cat("Bibliometric Summary for Transportation Safety",
    S,file = "biblio-summary.txt", sep = "\n")
plot(x = results, k = 10, pause = FALSE)

# Bibliographic Network Matrices
#-------------------------------
# [1] Sources - i.e. Journal Names
NetMatrix <- biblioNetwork(M, analysis = "coupling", 
                           network = "sources", 
                           sep = ";")
net=networkPlot(NetMatrix,  normalize = "salton", 
                weighted=NULL, n = 25, 
                Title = "Coupling of Journal Names", 
                type = "auto", size=13,size.cex=T,
                remove.multiple=TRUE,labelsize=0.55,
                label.n=25,label.cex=F,
                cluster="optimal",edges.min = 5)

#  [2] Create keyword co-occurrences network
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")
# Plot the network
net=networkPlot(NetMatrix, normalize="salton", 
                weighted=NULL, n = 60, 
                Title = "Keyword Co-Occurrences", 
                type = "auto", size=15,size.cex=T,
                remove.multiple=TRUE,labelsize=0.75,
                label.n=60,label.cex=F,
                cluster="optimal",edges.min = 5, label.color = TRUE,
                halo = TRUE)
netstat <- networkStat(NetMatrix)
out <- capture.output(summary(netstat, k=60))
cat("Network Statistics",
    S,file = "keyword-network-statistics.txt", 
    sep = "\n")


# [3] Creating a Conceptual Structure Map from the Titles
# Using the MCA Method with terms mentioned at least 25
# times in the title
CS <- conceptualStructure(M,field="ID_TM", method="MCA", 
                          minDegree=20, k.max=5, labelsize=15,
                          documents = 856)
