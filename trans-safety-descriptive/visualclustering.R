# This code attempts to replicate the visual clustering approach from
# Van Wijk, Jarke J., and Edward R. Van Selow. 1999. "Cluster and Calendar Based Visualization of Time Series Data." In Information Visualization, 1999.(Info Vis' 99) Proceedings. 1999 IEEE Symposium on, 4-9. IEEE.


# Cleaning screen and global environment
cat("\014") 
rm(list=ls())
graphics.off()


# Installing/loading relevant packages
library(pacman) # install.packages("pacman") if not on machine
p_load(data.table,devtools,
       ggplot2,plotly,extrafont,grDevices,RColorBrewer, ggthemes,
       dplyr, stringr,tidyverse,readr,
       rstudioapi,processx,
       ClusterR) # Assuming R Studio is the IDE
# automatically getting the file's wd using rstudio api
loadfonts(device = "win") # To use specific fonts for windows
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # only tested in

# Installing the GG Calendar Package from Github
install_github("jayjacobs/ggcal")
library(ggcal)

#_______________________Loading the Data_____________________________
trafficflow.df <- read_csv("georgia-TFdata-station-121-5505-Yr2015.csv")
trafficflow.df$Date <- as.Date(trafficflow.df$Date, format='%d-%b')

#________________________ Finding the Optimal Number of Clusters__________
# Ref: https://cran.r-project.org/web/packages/ClusterR/vignettes/the_clusterR_package.html
opt = Optimal_Clusters_KMeans(as.data.frame(trafficflow.df[,4:27]), max_clusters = 10, plot_clusters = T,
                              criterion = 'distortion_fK', fK_threshold = 0.85,
                              initializer = 'optimal_init', tol_optimal_init = 0.2,
                              max_iters = 10000)
num_clusters <- which.min(opt) # Based on the results, we should use k=2 clusters in kmeans
km = KMeans_arma(as.data.frame(trafficflow.df[,4:27]), clusters = num_clusters, n_iter = 10000, seed_mode = "random_subset", 
                 verbose = T, CENTROIDS = NULL)
pr = predict_KMeans(data.frame(trafficflow.df[,4:27]), km)
trafficflow.df$cluster.num <- as.vector(pr) %>% as.factor()
table(trafficflow.df$cluster.num)

summary.df <- group_by(trafficflow.df,cluster.num)
summary.df <- summarise_all(summary.df,funs(mean))
plot.df <- subset(summary.df, select = -c(2:4))
plot.df <- melt(plot.df, value.name="Traffic.Flow",
                        variable.name="Hour",id.vars="cluster.num")
plot.df$cluster.num <- as.factor(plot.df$cluster.num)

p1 <- ggplot(data = plot.df, aes(x = Hour, y = Traffic.Flow, group=cluster.num,
                           color=cluster.num)) + geom_line(size=2) +
  theme_bw() + 
  theme(legend.position="top", axis.text.x=element_text(angle=90, hjust=1)) +
  scale_color_brewer("Paired")
p1 

col.brewer.pal <- brewer.pal(11, "Paired")
mydate <- seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by="1 day")
p2 <- ggcal(mydate,trafficflow.df$cluster.num) + 
  theme(legend.position="top") +
  scale_fill_manual(values = c("1"=col.brewer.pal[1], "2"=col.brewer.pal[2]))
p2
