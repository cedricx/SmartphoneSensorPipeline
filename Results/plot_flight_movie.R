
gps_mob_video <- function(patient, day_i, gps_mobmat_hr){
  gps_movie_path <- file.path(output_filepath,"Results","Individual",patient,"gps_movie")
  dir.create(gps_movie_path, showWarnings = F)
  gps_mobmat_day <- gps_mobmat_hr[daily_index[[day_list[day_i]]],]
  
  xrang=plotlimits(gps_mobmat_day)$xrang
  yrang=plotlimits(gps_mobmat_day)$yrang
  
  
  for (t in 1:dim(gps_mobmat_day)[1]) {
    gps_time = round(hours(gps_mobmat_day$t1[t])['hours'],2)
    gps_hr = strsplit(as.character(gps_time),split = "[.]")[[1]][1]
    gps_min = round(as.numeric(strsplit(as.character(gps_time),split = "[.]")[[1]][2])*0.6,0)
    gps_hr = str_pad(gps_hr,2,pad="0")
    gps_min = str_pad(gps_min,2,pad="0")
    if (is.na(gps_min)) gps_min = 0
    gps_time_title = paste0("ID: ", substr(patient,1,6), ", Day: ",day_i,", Time: ", gps_hr,":",gps_min)
    png(file.path(gps_movie_path,paste0("day_",day_i,"_t",str_pad(t, 4, pad = "0"),".png")),width = 5,height = 5, units = 'in', res = 300)
      plot.flights2(gps_mobmat_day[1:t,],diminch = diminch, xrang = xrang, yrang= yrang,
                  addlegend = T, title = gps_time_title)
    dev.off()
  }
  
  png_files = file.path(gps_movie_path,paste0("day_", day_i,"_t*.png"))
  mpg_file = file.path(gps_movie_path,paste0(patient, "_day_",day_i,".mpg"))
  cat("\  creating movies")
  make.mov( speed = 1, png_files = png_files,  mpg_file = mpg_file)

}


for (patient in patient_names){
  cat("\nSubj: ", patient, "...",which(patient_names == patient),"/",length(patient_names))
  gps_mob_path <- file.path(output_filepath,"Processed_Data","Individual",patient,"gps_imputed_mobmat.rds")
  gps_mobmat <- readRDS(gps_mob_path)$mobmatsims[[1]]
  gps_hours <- hours(gps_mobmat[,4])
  gps_mobmat_hr <- cbind(gps_mobmat,gps_hours)
  daily_index <- daily_subsets(gps_mobmat)
  day_list <- names(daily_index)
  #data_start_day <- as.Date(day_list[1])
  #week_start_day <- floor_date(as.Date(day_list[1]), unit="week")
  #padding_day <- data_start_day - week_start_day
  #day_list <- prepend(day_list,rep("",padding_day),before = 1)
  
  for (day_i in 1:length(day_list)){
    cat("\n Day: ", day_i,"/",length(day_list))
    if (!nchar(day_list[day_i]) >0){
      cat("\  no data...skip")
    } else {
      gps_mob_video(patient = patient, day_i = day_i, gps_mobmat_hr = gps_mobmat_hr)
    }
  }
  
}
  