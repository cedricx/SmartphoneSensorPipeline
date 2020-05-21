### GPS plotting functions ###
minMiss_histplot<-function(data, bins, title="", tag ="", percent = T){
  total_days = dim(data)[1]
  if (percent == F) {
    p<-ggplot(data, aes(x=MinsMissing)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(MinsMissing == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(MinsMissing <= 1296))," days)")),linetype="dashed")
    
  } else {
    mean = round(mean(data$MinsMissing),0)
    percents = round(quantile(data$MinsMissing,prob = c(0.75, 0.8, 0.85, 0.9)),0)
    num_percent = sapply(percents, FUN = function(percent) length(which(data$MinsMissing <= percent)))
    legends = c()
    for (i in 1:length(percents)){
      legends[i] = paste0(names(percents[i])," (",percents[i]," min, n= ",num_percent[i]," days)")
    }
    
    p<-ggplot(data, aes(x=MinsMissing)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(MinsMissing == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(MinsMissing <= 1296))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=mean, color = paste0("mean (", mean, " min)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[1]), color = legends[1]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[2]), color = legends[2]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[3]), color = legends[3]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[4]), color = legends[4]),linetype="dashed") 
  }
  p +  ggtitle(title) + theme_cowplot() + labs(color = paste0("n=",total_days," days")) +
    xlab("Minutes Missing in a Day") + theme(plot.title = element_text(hjust = 0.5), legend.title.align = 0.5) + labs(tag = tag)
}