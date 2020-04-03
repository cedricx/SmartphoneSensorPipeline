old_dir = "~/Box/data_v2"
new_dir = "/Volumes/Storage/TDSlab/TedSleep/data_v2_chx/"

dir.create(file.path(new_dir), showWarnings = FALSE)
subj_names = list.files(old_dir)
for (subj in subj_names){
  cat("\nSubj: ", subj, "...",which(subj_names == subj),"/",length(subj_names))
  new_path = file.path(new_dir,subj)
  dir.create(new_path)
  
  #### "actigraphy" ####
  cat("\n cp actigraphy")
  old_acti_path = file.path(old_dir,subj,"actigraphy")
  new_acti_path = file.path(new_dir,subj,"actigraphy")
  if(file.exists(old_acti_path)) {
      file.copy(old_acti_path,new_path,recursive = TRUE, overwrite = FALSE)
      } else { cat("\n  no actigraphy") }
  
  #### "beiwe" ####
  cat("\n cp beiwe")
  old_beiwe_path = file.path(old_dir,subj,"beiwe")
  if(file.exists(old_beiwe_path)) {
    new_beiwe_path = file.path(new_path,"beiwe")
    dir.create(new_beiwe_path, showWarnings = FALSE)
    
    periods = list.files(old_beiwe_path)
    periods = periods[periods!="archive"]
    if (length(grep("incorrect*",periods)) >0 ) {
      periods = periods[-grep("incorrect*",periods)]
    }
    for (period in periods){
      period_path = file.path(old_beiwe_path,period)
      if (length(list.files(period_path)) > 0) {
        cat("\n   period: ", period, length(list.files(period_path,recursive = T)), "files")
        setwd(period_path)
        file.copy(list.files(period_path),new_beiwe_path,recursive = TRUE, overwrite = FALSE)
      } else {
        cat("\n   period: no file in", period)
      }
    } 
  } else { cat("\n  no beiwe") }
}
