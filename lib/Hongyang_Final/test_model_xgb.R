xgb_train <- function(dat_train, label_train, max.depth = 5, nround = 100,run.cv=F){
  library(xgboost)
  
  train_df <- data.matrix(dat_train)
  label <- label_train
  #train_df$label <- label_train
  #train_df <- data.matrix(train_df)
  if(run.cv){
    list_max.depth <- c(5,20,50,100)
    #list_max.depth <- c(5,10)
    #list_eta <-  c()
    #list_nround <- c(10,20)
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




xgb_test <- function(model,dat_test, label_test){
  pred_label <- predict(model, data.matrix(dat_test))
  #return(mean(pred_label==label_test))
  return(pred_label)
}


library(xgboost)


label <- read.csv("../data/label_train.csv")
label <- (label[,2])

train_model_feature=cbind(features,HOG_features,lbp_features,gray_feature)
test_model_feature=cbind(sift5000_test,feature_hog_test,lbp_test,feature_gray_test)

train_label=label


train_xgb=train_model_feature
test_xgb=test_model_feature


xgb.train.start=Sys.time()
xgb_pca_fit=xgb_train(train_xgb,train_label)
xgb.train.end=Sys.time()
xgb.running=xgb.train.end-xgb.train.start
xgb.running


xgb.test.start=Sys.time()
predict_xgb=xgb_test(xgb_pca_fit,test_xgb)
xgb.test.end=Sys.time()
xgb.running.test=xgb.test.end-xgb.test.start
xgb.running.test

sum(predict_xgb==0)
sum(predict_xgb==1)
sum(predict_xgb==2)

save(train_model_feature,file="train_model_feature.RData")
save(test_model_feature,file="test_model_feature.RData")
save(xgb_pca_fit,file="xgb_fit.RData")
