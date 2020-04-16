library(ggplot2)
library(cowplot)
library(gridExtra)

featureMat<-readRDS(file.path(output_filepath,"Processed_Data","Group","feature_matrix_clean.RDS"))[[1]]
minutesMissing <- data.frame(mins = as.numeric(featureMat$MinsMissing))

minMiss_histplot<-function(data, bins, percent = T){
  total_days = dim(data)[1]
  if (percent == F) {
    p<-ggplot(data, aes(x=mins)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(data == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(data <= 1296))," days)")),linetype="dashed") +
      xlab("Minutes Missing in a Day")
    p + theme_cowplot() + labs(color = paste0("Cutoffs (n=",total_days," days)"))
  } else {
    mean = round(mean(data$mins),0)
    percents = round(quantile(data$mins,prob = c(0.75, 0.8, 0.85, 0.9)),0)
    num_percent = sapply(percents, FUN = function(percent) length(which(data$mins <= percent)))
    legends = c()
    for (i in 1:length(percents)){
      legends[i] = paste0(names(percents[i])," (",percents[i]," min, n= ",num_percent[i],"days)")
    }
    
    p<-ggplot(data, aes(x=mins)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(data == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(data <= 1296))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=mean, color = paste0("mean (", mean, " min)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[1]), color = legends[1]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[2]), color = legends[2]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[3]), color = legends[3]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[4]), color = legends[4]),linetype="dashed") +
      xlab("Minutes Missing in a Day")
    p + theme_cowplot() + labs(color = paste0("Cutoffs (n=",total_days," days)")) #+ theme(legend.position="bottom")
  }
}

mins_hist_full <-minMiss_histplot(minutesMissing, 200, percent= F)
mins_hist_part <-minMiss_histplot(subset(minutesMissing, mins >= 1296), 200, percent= F)
mins_hist_part_cutoff <-minMiss_histplot(subset(minutesMissing, mins >= 1296), 200, percent= T)
par(mfrow=c(3 ,1))
mins_hist_full
mins_hist_part
mins_hist_part_cutoff
grid.arrange(mins_hist_full, mins_hist_part,mins_hist_part_cutoff, nrow = 3)
