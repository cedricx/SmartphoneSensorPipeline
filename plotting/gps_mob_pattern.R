patient_names
patient = patient_names[1]

gps_mob_path <- file.path(output_filepath,"Processed_Data","Individual",patient,"gps_imputed_mobmat.rds")
gps_mobmat <- readRDS(gps_mob_path)$mobmatsims[[1]]
gps_hours <- hours(gps_mobmat[,4])
gps_mobmat_hr <- cbind(gps_mobmat,gps_hours)

xrang=plotlimits(gps_mobmat_hr)$xrang
yrang=plotlimits(gps_mobmat_hr)$yrang


daily_index <- daily_subsets(gps_mobmat)

gps_days <- unique(gps_mobmat_hr$days)
par(mfrow=c(6,4))
for (gps_day in gps_days){
  gps_mobmat_day <- gps_mobmat_hr[daily_index[[gps_day]],]
  title = paste("ID:",substr(patient,1,6),"on",substring(weekdays.Date(as.Date(gps_day)),1,3),gps_day)
  diminch = 10
  plot.flights2(gps_mobmat_day,diminch = diminch, 
                xrang = xrang, yrang = yrang,
                title = title)
  plot.flights2(gps_mobmat_day,diminch = diminch,
                title = title)
}
