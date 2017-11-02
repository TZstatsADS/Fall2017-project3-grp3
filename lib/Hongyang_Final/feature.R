#source('./HOG.R')
#source('./PCA.R')
extract_feature <- function(origin_sift,dir_image){
  #pca_sift <- feature.pca(origin_sift)
  hog <-  HOG_extract(dir_image)
  gray <- gray_extractFeature(dir_image)
  final_feature <- cbind(origin_sift,hog,gray)
  
  return(final_feature)
}

#####HOG Extract Features#####
HOG_extract <- function(dir_image,include_sift=F){
  
  if(!require(EBImage)){
    source("http://bioconductor.org/biocLite.R")
    biocLite("EBImage")
  }
  if(!require(OpenImageR)){
    install.packages("OpenImageR")
  }
  library(OpenImageR)
  library(EBImage)
  
  dir_names <- list.files(dir_image)
  HOG_df <- data.frame(matrix(nrow = length(dir_names), ncol = 448))
  for(i in 1:length(dir_names)) {
    HOG_df[i,]<-HOG(readImage(paste0(dir_image,"/",dir_names[i])),cells = 8,orientations = 7)
  } 
  
  #load('../output/train_index')
  
  # if(include_sift==T){
  #   sift_train <- read.csv('../training_set/sift_train.csv',as.is = T)[,-1]
  #   feature <- cbind(sift_train,HOG_df)
  #   
  # }
  # else{
  #   feature <- HOG_df
  # }
  
  return(HOG_df)
  
  
  
}

#####PCA Extract Features#####
feature.pca <- function(dat_feature, threshold=0.9, plot=FALSE){
  
  # Run PCA on features
  feature.pca <- prcomp(as.data.frame(dat_feature), center = TRUE, scale = TRUE)
  summary.pca <- summary(feature.pca)
  sd.pca <- summary.pca$sdev
  prop_var <- summary.pca$importance[2, ]
  cum_var <- summary.pca$importance[3,]
  
  # PCA threshold values
  thre <- which(cum_var >= threshold)[1]
  
  if (plot == TRUE){
    # PCA visualization
    png(filename=paste("../../figs/pca visualization", threshold, ".png"))
    op <- par(mfrow=c(1,2))
    plot(seq(1,length(sd.pca), by=1), prop_var, type="l", 
         xlab = "PCA", ylab = "Proportion of variance",
         main = "Proportion of Variance")
    abline(h=prop_var[thre], col="red")
    abline(v=thre, col="blue")
    points(x=thre, y=prop_var[thre], pch="+", col="red")
    
    cum_var <- summary.pca$importance[3,]
    plot(seq(1,length(sd.pca), by=1), cum_var, type="l", 
         xlab = "PCA", ylab = "Cumulation of variance",
         main = "Cumulation of Variance")
    abline(h=threshold, col="red")
    abline(v=thre, col="blue")
    points(x=thre, y=threshold, pch="+", col="red")
    par(op)
    dev.off()
    
  }
  # Extract first N PCAs based on threshold values
  pca_thre <- as.matrix(dat_feature) %*% feature.pca$rotation[,c(1:thre)]
  
  # save file
  #save(pca_thre, file = paste("../../output/extracted.pca", threshold, ".RData"))
  
  return(pca_thre)
}


#####################get gray features by doing quantiles################
img_dir <- "../data/images" #change to image directory
start.time=Sys.time()
gray_extractFeature=function(img_dir){

  n_files <- length(list.files(img_dir))
  
  gray_feature <- matrix(NA, nrow = n_files, ncol = 256)
  for(i in 1:n_files){
    ii <- str_pad(i, 4, pad = "0")
    #read image file
    img <- readImage(paste0(img_dir, "/","img_", ii,".jpg"))
    #change to gray image
    grayimg <- channel(img, "gray")
    mat <- imageData(grayimg)
    n <- 256
    nBin <- seq(0, 1, length.out = n)
    #divide into 256 quantiles and count the frequency
    freq_gray <- as.data.frame(table(factor(findInterval(mat, nBin), levels = 1:n)))
    #normalization and store the features
    gray_feature[i,]<- as.numeric(freq_gray$Freq)/(ncol(mat)*nrow(mat))
  }
  return(gray_feature)
}

end.time=Sys.time()
gray.running=end.time-start.time
#save(gray_feature,file='../data/features/gray_feature256.RData')