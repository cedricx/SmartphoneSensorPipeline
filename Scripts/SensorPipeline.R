################################################################
################    Beiwe Master Pipeline    ###################
################################################################

source_filepath    = "C:/Users/Ian/Documents/Beiwe-Analysis-master"
data_filepath      = "C:/Users/Ian/Documents/SZtorous2/data"
output_filepath    = "C:/Users/Ian/Documents/SZtorous2/output"



# Source all files
source(paste(source_filepath, "Utility/Initialize.R",sep="/"))


###################################
### individual patient analysis ###
###################################

for(patient_name in patient_names){
  cat("\n",patient_name,"\n")
  # Preprocess Data
  surveys_preprocessing(patient_name)
  text_preprocessing(patient_name)
  calls_preprocessing(patient_name)
  powerstate_preprocessing(patient_name)
  accelerometer_preprocessing(patient_name, minutes = acc_binsize)
  GPS_preprocessing(patient_name)
  # Process Data
  GPS_imputation(patient_name,nreps=1)
  CreateMobilityFeatures(patient_name)
  # Results
  ContinuousDataCollectionTracks(patient_name, acc_binsize)
}
print("completed!")
#####################################
#### combined patient processing ####
#####################################


daily_features()
fill_in_NAs()



#####################################
#### survey questions            ####
#####################################

# surveycols = 5:29 # Columns of the feature matrix that correspond to survey questions (to be duplicated)
# daysback = 2      # Number of days prior to taking a survey that the survey responses are still pertinent
# 
# replicate_survey_responses_backwards(surveycols,daysback) # Create a feature matrix that applies survey responses to the daysback days prior to taking each survey. Essentially adding duplicates.
# 
# labels = c("Anxiety","Depression","Meds","Sleep","Psychosis","WSS") # labels for the resulting groupings after combination. Must be the same length as the "groupings" lists. The groupings list specifies which column indices of the input feature matrix should be combined together
# groupings = list()
# groupings[[1]] = c(5,8,10,16,18,26)
# groupings[[2]] = c(7,9,23,24,27,14,17,19)
# groupings[[3]] = c(11)
# groupings[[4]] = c(7,15,24,25)
# groupings[[5]] = c(10,20,28,29)
# groupings[[6]] = c(5,6,7,9,14,15,16,23,24,25,27)
# 
# combine_survey_responses(surveycols,groupings,labels)
# 










