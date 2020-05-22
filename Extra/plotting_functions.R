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
    percents = round(quantile(data$MinsMissing,prob = c(0.75, 0.8, 0.85, 0.9), na.rm=TRUE),0)
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


### cor plot enhanced ###
rquery.cormat <-function(x, type=c('lower', 'upper', 'full', 'flatten'),
         graph=TRUE, graphType=c("correlogram", "heatmap"),
         col=NULL, ...)
{
  library(corrplot)
  # Helper functions
  #+++++++++++++++++
  # Compute the matrix of correlation p-values
  cor.pmat <- function(x, ...) {
    mat <- as.matrix(x)
    n <- ncol(mat)
    p.mat<- matrix(NA, n, n)
    diag(p.mat) <- 0
    for (i in 1:(n - 1)) {
      for (j in (i + 1):n) {
        tmp <- cor.test(mat[, i], mat[, j], na.action = na.omit,...)
        p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
      }
    }
    colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
    p.mat
  }
  # Get lower triangle of the matrix
  getLower.tri<-function(mat){
    upper<-mat
    upper[upper.tri(mat)]<-""
    mat<-as.data.frame(upper)
    mat
  }
  # Get upper triangle of the matrix
  getUpper.tri<-function(mat){
    lt<-mat
    lt[lower.tri(mat)]<-""
    mat<-as.data.frame(lt)
    mat
  }
  # Get flatten matrix
  flattenCorrMatrix <- function(cormat, pmat) {
    ut <- upper.tri(cormat)
    data.frame(
      row = rownames(cormat)[row(cormat)[ut]],
      column = rownames(cormat)[col(cormat)[ut]],
      cor  =(cormat)[ut],
      p = pmat[ut]
    )
  }
  # Define color
  if (is.null(col)) {
    col <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", 
                              "#F4A582", "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE", 
                              "#4393C3", "#2166AC", "#053061"))(200)
    col<-rev(col)
  }
  
  # Correlation matrix
  cormat<-signif(cor(x, use = "pairwise.complete.obs", ...),2)
  pmat<-signif(cor.pmat(x, ...),2)
  # Reorder correlation matrix
  #ord<-corrMatOrder(cormat, order="alphabet")
  #cormat<-cormat[ord, ord]
  #pmat<-pmat[ord, ord]
  # Replace correlation coeff by symbols
  sym<-symnum(cormat, abbr.colnames=FALSE)
  # Correlogram
  if(graph & graphType[1]=="correlogram"){
    corrplot(cormat, method = "color", type=ifelse(type[1]=="flatten", "lower", type[1]),
             tl.col="black", tl.srt=45,col=col,...)
  }
  else if(graphType[1]=="heatmap")
    heatmap(cormat, col=col, symm=TRUE)
  # Get lower/upper triangle
  if(type[1]=="lower"){
    cormat<-getLower.tri(cormat)
    pmat<-getLower.tri(pmat)
  }
  else if(type[1]=="upper"){
    cormat<-getUpper.tri(cormat)
    pmat<-getUpper.tri(pmat)
    sym=t(sym)
  }
  else if(type[1]=="flatten"){
    cormat<-flattenCorrMatrix(cormat, pmat)
    pmat=NULL
    sym=NULL
  }
  list(r=cormat, p=pmat, sym=sym)
}




