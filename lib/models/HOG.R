
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
  
  load('../output/train_index')
  
  if(include_sift==T){
    sift_train <- read.csv('../training_set/sift_train.csv',as.is = T)[,-1]
    feature <- cbind(sift_train,HOG_df)
      
  }
  else{
    feature <- HOG_df
  }
    
  
  
  
  return(feature)
  
  
  
}

  
tm_extract_HOG <- system.time(HOG_features <- HOG_extract('../training_set/images'))

write.csv(HOG_features,'../output/HOG_features_train')
save(HOG_features,file='../output/HOG_features_train.RData')  

dir_image <- '../training_set/images'
  
tm_extract_HOG
## 488



