EMA <- featureMat_trunc[,1:89]
library(MICE)
library(VIM)
AM_only_1<-EMA[,c(1:2,3:12)]
RN_only_1<-EMA[,c(1:2,13:21)]
beep_only_1<-EMA[,c(1:2,22:28)]
rn_only_2<-EMA[,c(1:2,29:37)]
beep_only_2<-EMA[,c(1:2,38:44)]
weekly_only_1<-EMA[,c(1:2,45:58)]
beep_only_3<-EMA[,c(1:2,59:60)]
weekly_only_2<-EMA[,c(1:2,61:74)]
rn_only_3<-EMA[,c(1:2,75)]
weekly_only_3<-EMA[,c(1:2,76:89)]