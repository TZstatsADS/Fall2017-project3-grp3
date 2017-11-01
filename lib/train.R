#source('./gbm.R')
#source('./xgboost.R')

gbm_train <- function(dat_train, label_train, n.trees=250,n.shrinkage=0.1,run.cv=F){
  library('gbm')
  
  train_df <- dat_train
  train_df$label <- label_train
  if(run.cv){
    list_ntrees <- c(150,250,300,500)
    list_shrinkage = c(0.01,0.1)
    
    errors <- matrix(NA,nrow=length(list_ntrees),ncol = length(list_shrinkage))
    
    for(j in 1:length(list_ntrees)){
      for(k in 1:length(list_shrinkage)){
        errors[j,k] <- gbm.cv.f(train_df, list_ntrees[j],list_shrinkage[k])
      }
    }
    
    row_index <- which(errors == min(errors), arr.ind = TRUE)[1]
    col_index <- which(errors == min(errors), arr.ind = TRUE)[2]
    
    best.n.trees <- list_ntrees[row_index]
    best.shrinkage <- list_shrinkage[col_index]
    
    print(errors)
    save(errors,file='../output/base_errors.RData')
    
    cat('best number of tress is: ',best.n.trees)
    cat('\n')
    cat('best number of shrinkage is: ', best.shrinkage)
  } else{
    best.n.trees <- n.trees
    best.shrinkage <- n.shrinkage
    
  }
  
  
  
  
  best_gbm_fit <- gbm(label~ ., 
                      data = train_df,
                      interaction.depth = 1,
                      distribution="multinomial",
                      n.trees = best.n.trees, 
                      shrinkage = best.shrinkage)
  return(best_gbm_fit)
  
}








xgb_train <- function(dat_train, label_train, max.depth = 5, nround = 100,run.cv=F){
  library(xgboost)
  
  train_df <- data.matrix(dat_train)
  label <- label_train
  #train_df$label <- label_train
  #train_df <- data.matrix(train_df)
  if(run.cv){
    list_max.depth <- c(5,20,50,100)
    #list_max.depth <- c(100,200,500)
    #list_max.depth <- c(150,200,300)
    #list_eta <-  c()
    
    list_nround <- c(10,25,100,200)
    
    errors <- matrix(NA,nrow=length(list_max.depth),ncol = length(list_nround))
    
    for(j in 1:length(list_max.depth)){
      for(k in 1:length(list_nround)){
        errors[j,k] <- xgb.cv.f(train_df, label,list_max.depth[j],list_nround[k])
      }
    }
    
    row_index <- which(errors == min(errors), arr.ind = TRUE)[1]
    col_index <- which(errors == min(errors), arr.ind = TRUE)[2]
    
    best.max.depth <- list_max.depth[row_index]
    best.nround <- list_nround[col_index]
    
    print(errors)
    save(errors,file='../output/xgb_errors.RData')
    cat('best number of max depth is: ',best.max.depth)
    cat('\n')
    cat('best number of nround is: ', best.nround)
    
  } else{
    best.max.depth <- max.depth
    best.nround <- nround
    
  }
  
  
  
  
  
  
  best_xgb_fit <- xgboost(data = train_df, 
                          label = label_train, 
                          max.depth = best.max.depth, 
                          eta = 0.3, 
                          nround = best.nround,
                          objective = "multi:softmax",
                          num_class=3,
                          verbose = 0)
  
  return(best_xgb_fit)
  
}




