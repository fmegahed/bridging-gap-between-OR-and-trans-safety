
# Cleaning screen and global environment
cat("\014") 
rm(list=ls())
graphics.off()

library(pacman)
p_load(forecast, ggplot2, devtools)

