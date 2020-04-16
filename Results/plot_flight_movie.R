
gps_mob_video <- function(patient, day_i, gps_mobmat_hr){
  gps_mobmat_day <- gps_mobmat_hr[daily_index[[i]],]
  
  xrang=plotlimits(gps_mobmat_day)$xrang
  yrang=plotlimits(gps_mobmat_day)$yrang
  
  
  for (t in 1:dim(gps_mobmat_day)[1]) {
    gps_time = round(hours(gps_mobmat_day$t1[t])['hours'],2)
    gps_hr = strsplit(as.character(gps_time),split = "[.]")[[1]][1]
    gps_min = round(as.numeric(strsplit(as.character(gps_time),split = "[.]")[[1]][2])*0.6,0)
    gps_hr = str_pad(gps_hr,2,pad="0")
    gps_min = str_pad(gps_min,2,pad="0")
    if (is.na(gps_min)) gps_min = 0
    gps_time_title = paste(gps_hr,gps_min,sep = ":")
    png(file.path(output_filepath,"Results","Individual",patient,"gps_movie",paste0("day_",day_i,"_t",str_pad(t, 4, pad = "0"),".png")),width = 5,height = 5, units = 'in', res = 300)
      plot.flights2(gps_mobmat_day[1:t,],diminch = diminch, xrang = xrang, yrang= yrang,
                  addlegend = T, title = gps_time_title)
    dev.off()
  }
  

  make.mov( speed = 1,day_i)
  png_files = paste0("day_", day_i,"_t*.png")
  mpg_file = paste0(patient, "_day_",day_i,".mpg")
  file.remove(list=list.files(pattern = "*png$"))
}
