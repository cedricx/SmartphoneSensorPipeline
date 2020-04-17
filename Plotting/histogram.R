library(ggplot2)
library(cowplot)
library(gridExtra)
require(dplyr) 
library(ggExtra)
library(ggpubr)


source_filepath    = "~/Documents/GitHub/SmartphoneSensorPipeline/"
data_filepath      = "/Volumes/Storage/TDSlab/TedSleep/data_v2_beiwe/"
output_filepath    = "~/Documents/beiwe_output"
featureMat<-readRDS(file.path(output_filepath,"Processed_Data","Group","feature_matrix_clean.RDS"))[[1]]
featureMat_trunc = data.frame()
for (id in unique(featureMat$IID)){
  featMat_id <- subset(featureMat, IID == id)
  featMat_id <- featMat_id[2:(dim(featMat_id)[1]-1),]
  featureMat_trunc <- rbind(featureMat_trunc,featMat_id)
}

featureMat_dataends <- anti_join(featureMat,featureMat_trunc)
###########
featureMat_trunc$ID_abb <- unlist(lapply(featureMat_trunc$IID,function(long_id) substr(long_id,1,5)))



##########

minutesMissing<- data.frame(mins = as.numeric(featureMat_trunc$MinsMissing))

minMiss_histplot<-function(data, bins, title="", tag ="", percent = T){
  total_days = dim(data)[1]
  if (percent == F) {
    p<-ggplot(data, aes(x=mins)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(data == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(data <= 1296))," days)")),linetype="dashed")
      
  } else {
    mean = round(mean(data$mins),0)
    percents = round(quantile(data$mins,prob = c(0.75, 0.8, 0.85, 0.9)),0)
    num_percent = sapply(percents, FUN = function(percent) length(which(data$mins <= percent)))
    legends = c()
    for (i in 1:length(percents)){
      legends[i] = paste0(names(percents[i])," (",percents[i]," min, n= ",num_percent[i]," days)")
    }
    
    p<-ggplot(data, aes(x=mins)) + 
      geom_histogram(fill="lightgrey",bins = bins) +
      geom_vline(data=data, aes(xintercept=1440, color = paste0("Missing all data (1440 min, n= ", length(which(data == 1440))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=1296, color = paste0("Missing no data (1296 min, n= ", length(which(data <= 1296))," days)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=mean, color = paste0("mean (", mean, " min)")),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[1]), color = legends[1]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[2]), color = legends[2]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[3]), color = legends[3]),linetype="dashed") +
      geom_vline(data=data, aes(xintercept=as.numeric(percents[4]), color = legends[4]),linetype="dashed") 
  }
  p +  ggtitle(title) + theme_cowplot() + labs(color = paste0("n=",total_days," days")) +
    xlab("Minutes Missing in a Day") + theme(plot.title = element_text(hjust = 0.5), legend.title.align = 0.5) + labs(tag = tag)
}

mins_hist_full_notrunc <-minMiss_histplot(data.frame(mins = as.numeric(featureMat$MinsMissing)), 
                                          200, percent= F, title = "all data", tag ="a")
mins_hist_dataends <- minMiss_histplot(data.frame(mins = as.numeric(featureMat_dataends$MinsMissing)),
                                       200, percent= F, title = "first and last days only", tag = "b")
mins_hist_full <-minMiss_histplot(minutesMissing, 200, percent= F, title = "data excl. first and last day", "c")
mins_hist_low <-minMiss_histplot(subset(minutesMissing, mins < 1296), 200, percent= F, title = "data below 1296 (excl 1st/last days)","d")
mins_hist_part <-minMiss_histplot(subset(minutesMissing, mins >= 1296), 200, percent= F, title = "data above 1296 (excl 1st/last days)","e")
mins_hist_part_cutoff <-minMiss_histplot(subset(minutesMissing, mins >= 1296), 200, percent= T, title =  "data above 1296 with cutoffs (excl 1st/last days)","f")

pdf(file.path(output_filepath,"Processed_Data","Group","missingData_histogram.pdf"),width = 15,height = 10)
grid.arrange(mins_hist_full_notrunc, mins_hist_dataends, mins_hist_full,mins_hist_low,
             mins_hist_part,mins_hist_part_cutoff, nrow = 6)
dev.off()


###############################################################################
featureMat_trunc$MinsMissing <- as.numeric(featureMat_trunc$MinsMissing)
featureMat_trunc$ProbPause <- as.numeric(featureMat_trunc$ProbPause)
featureMat_trunc_ID_count <- as.data.frame(table(featureMat_trunc$ID_abb))
colnames(featureMat_trunc_ID_count) <- c("ID","count")
cutoffs <- c(.75,0.8,0.9)
cutoffs_plots = list()
cutoffs_plots_percent = list()
for (cutoff in cutoffs){
  cutoff_val <- round(quantile(featureMat_trunc$MinsMissing,cutoff),0)
  featMat_cutoff = subset(featureMat_trunc, MinsMissing>cutoff_val)
  featMat_cutoff_ID_count <- as.data.frame(table(featMat_cutoff$ID_abb))
  colnames(featMat_cutoff_ID_count) <- c("ID","count")
  featMat_cutoff_ID_count <- merge(featureMat_trunc_ID_count,featMat_cutoff_ID_count,by = "ID")
  colnames(featMat_cutoff_ID_count) <- c("ID","count_total","count_cutoff")
  featMat_cutoff_ID_count$count_percent <- featMat_cutoff_ID_count$count_cutoff / featMat_cutoff_ID_count$count_total
  p<-ggplot(featMat_cutoff_ID_count, aes(reorder(ID,count_cutoff/dim(featMat_cutoff)[1]),count_cutoff/dim(featMat_cutoff)[1]))+ 
    geom_bar(fill = "red", alpha = cutoff*3-2, stat="identity")  + xlab("ID") + ylim(c(0,0.25)) +
    ggtitle(paste("Cutoff at ",cutoff, ", n =",dim(featMat_cutoff)[1])) + ylab("Percent of all days with mins \n missing at this level") +
    coord_flip() + theme_cowplot() + theme(plot.title = element_text(hjust = 1))
  cutoffs_plots[[which(cutoffs == cutoff)]] = p
  q<-ggplot(featMat_cutoff_ID_count, aes(reorder(ID,count_percent),count_percent))+ 
    geom_bar(fill = "orange", alpha = cutoff*3-2, stat="identity")  + xlab("ID") + ylim(c(0,1)) +
    ggtitle(paste("Cutoff at ",cutoff, ", n =",dim(featMat_cutoff)[1])) + ylab("Percent of all days recorded \n for this subject") +
    coord_flip() + theme_cowplot() + theme(plot.title = element_text(hjust = 1))
  cutoffs_plots_percent[[which(cutoffs == cutoff)]] = q
  }
pdf(file.path(output_filepath,"Processed_Data","Group","missingData_bargraph.pdf"),width = 10,height = 12)
do.call("grid.arrange", c(cutoffs_plots, cutoffs_plots_percent, ncol=3, nrow=2))
dev.off()


#####################33
missing_scatter_plots <- list()
miss_points <- list(all_data = c(0,1440),excl_low_missing = c(1296,1440), excl_high_missing = c(0,1433), excl_low_and_high_missing = c(1296,1433))
for (i in 1:length(miss_points) ){
miss_point = miss_points[[i]]
miss_point_df <-subset(featureMat_trunc, MinsMissing>=miss_point[1] & MinsMissing <= miss_point[2])
#miss_point_df <- subset(miss_point_df, ProbPause < 1)
miss_point_df <- data.frame(mins = as.numeric(miss_point_df$MinsMissing), ProbPause = as.numeric(miss_point_df$ProbPause))
cor.test(miss_point_df$mins,miss_point_df$ProbPause,use = "na.or.complete")

formula <- y ~ x
p<-ggplot(miss_point_df, aes(x=mins, y=ProbPause) ) +
  geom_point(color = "lightgrey") +stat_smooth(color="black", method = "lm", formula = formula) +
  stat_regline_equation(
    aes(label =  paste(..eq.label.., ..rr.label.., sep = "~~~~")),
    formula = formula
  ) + theme_cowplot()  + ggtitle(paste(unlist(strsplit(names(miss_points)[i],split = "_")), collapse = " ")) +
  theme (plot.title = element_text(hjust = 0.5))

missing_scatter_plots[[names(miss_points)[i]]]<-ggMarginal(p, type="histogram", colour = "lightgrey", fill = "lightgrey",size = 5)

}
pdf(file.path(output_filepath,"Processed_Data","Group","missing_pause_cor.pdf"),width = 8,height = 8)
do.call("grid.arrange", c(missing_scatter_plots, ncol=2, nrow=2))
dev.off()
