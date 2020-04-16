
gps_mob_video <- function(patient, day_i, gps_mobmat_hr, overwrite = T){
  gps_movie_path <- file.path(output_filepath,"Results","Individual",patient,"gps_movie")
  dir.create(gps_movie_path, showWarnings = F)
  png_files = file.path(gps_movie_path,paste0("day_", str_pad(day_i,3,pad = "0"),"_t*.png"))
  mpg_file = file.path(gps_movie_path,paste0(patient, "_day_",str_pad(day_i,3,pad = "0"),".mpg"))
  
  gps_mobmat_day <- gps_mobmat_hr[daily_index[[day_list[day_i]]],]
  
  if(overwrite == T | !file.exists(mpg_file) | !file.info(mpg_file)$size >0){
    day_png_files(gps_mobmat_day)
    cat("\  creating new movies")
    make.mov( speed = 1, png_files = png_files,  mpg_file = mpg_file)
  } else {
    cat("\  movie already exists")
    }
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
      gps_mob_video(patient = patient, day_i = day_i, gps_mobmat_hr = gps_mobmat_hr, overwrite = F)
    }
  }
  
}
  