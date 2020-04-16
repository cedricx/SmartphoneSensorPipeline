patient_names
for (patient in patient_names){
  cat("\nSubj: ", patient, "...",which(patient_names == patient),"/",length(patient_names))
  gps_mob_path <- file.path(output_filepath,"Processed_Data","Individual",patient,"gps_imputed_mobmat.rds")
  gps_mobmat <- readRDS(gps_mob_path)$mobmatsims[[1]]
  gps_hours <- hours(gps_mobmat[,4])
  gps_mobmat_hr <- cbind(gps_mobmat,gps_hours)
  gps_null <- data.frame(code=2,x0=0,y0=0,t0=1555546750,
                         x1=NA,y1=NA,t1=1555546751,hours=20,days='2019-04-17')
  daily_index <- daily_subsets(gps_mobmat)
  gps_days <- unique(gps_mobmat_hr$days)
  num_days <- as.numeric(as.Date(gps_days[length(gps_days)]) - as.Date(gps_days[1]))
  num_weeks = floor((num_days+4) / 7) + 1
  
  day_list <- names(daily_index)
  data_start_day <- as.Date(day_list[1])
  week_start_day <- floor_date(as.Date(day_list[1]), unit="week")
  padding_day <- data_start_day - week_start_day
  day_list <- prepend(day_list,rep("",padding_day),before = 1)
  dayofweek = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")
  xrang=plotlimits(gps_mobmat_hr)$xrang
  yrang=plotlimits(gps_mobmat_hr)$yrang
  
  
  pdf(file.path(output_filepath,"Results","Individual",patient,"gps_mob_nonscaled.pdf"),
      height = 8,width = 11)
  par(mfrow=c(5 ,7))
    for (i in 1:length(day_list)){
      gps_day = day_list[i]
      if (i<=7){
        if (!nchar(gps_day)>0) {
          gps_mobmat_day <- gps_null
          plot.flights2(gps_mobmat_day, title = dayofweek[i], addscale = F, addlegend = F)
        } else {
          gps_mobmat_day <- gps_mobmat_hr[daily_index[[gps_day]],]
          plot.flights2(gps_mobmat_day, #xrang = xrang, yrang= yrang,
                        title = dayofweek[i])
        }
      } else {
        if (!nchar(gps_day)>0) {
          gps_mobmat_day <- gps_null
          plot.flights2(gps_mobmat_day, addscale = F, addlegend = F)
        } else {
          gps_mobmat_day <- gps_mobmat_hr[daily_index[[gps_day]],]
          diminch = 10
          plot.flights2(gps_mobmat_day,diminch = diminch, #xrang = xrang, yrang= yrang,
                        addlegend = T)
        }
      }
    }
  dev.off()
}
  